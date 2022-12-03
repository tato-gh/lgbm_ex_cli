defmodule LGBMExCli do
  @moduledoc """
  Documentation for `LGBMExCli`.
  """

  @ng_not_fount_cmd {
    :ng,
    "LightGBM is NOT executable. Please set application config `lightgbm_cmd` to execute, like `config :lgbm_ex_cli, lightgbm_cmd: <Your microsoft/LightGBM cmd file path>`"
  }

  @doc """
  Fit model

  Returns the model filepath when not using early stoppping.
  Returns the model filepath, num_iterations and eval_value when using early stopping.

  The num_iterations and eval_value are taken from LightGBM CLI log string. It is shown when using early_stopping only.
  """
  def fit(workdir, features, labels, params \\ [])

  def fit(workdir, features, labels, params) when is_list(features) do
    files = collect_cli_train_files(workdir)
    params = defacto_train_params(files) |> Keyword.merge(params)
    :ok = make_data_csv_file(features, labels, files.data)
    :ok = make_train_config_file(files, params)

    if cmd_executable?() do
      {:ok, _num_iterations, _eval_value} = exec_lightgbm_train(files, params)
      {:ok, files.model}
    else
      @ng_not_fount_cmd
    end
  end

  def fit(workdir, {features_t, features_v}, {labels_t, labels_v}, params) do
    files = collect_cli_train_files(workdir)
    params =
      defacto_train_params(files)
      |> Keyword.merge(params)
      |> Keyword.put(:valid_data, files.validation)
      |> Keyword.put(:verbosity, 1)
    :ok = make_data_csv_file(features_t, labels_t, files.data)
    :ok = make_data_csv_file(features_v, labels_v, files.validation)
    :ok = make_train_config_file(files, params)

    if cmd_executable?() do
      {:ok, num_iterations, eval_value} = exec_lightgbm_train(files, params)
      {:ok, files.model, num_iterations, eval_value}
    else
      @ng_not_fount_cmd
    end
  end

  @doc """
  ReFit model on the params (to dig better parameters).
  """
  def refit(workdir, params) do
    files = collect_cli_train_files(workdir)
    current_params = parse_config_file(files)
    new_params = Keyword.merge(current_params, params)
    :ok = make_train_config_file(files, new_params)

    if cmd_executable?() do
      {:ok, num_iterations, eval_value} = exec_lightgbm_train(files, params)
      {:ok, files.model, num_iterations, eval_value}
    else
      @ng_not_fount_cmd
    end
  end

  @doc """
  Predict data

  Returns the cli outputs.
  """
  def predict(model_file, features) do
    files = collect_cli_prediction_files(model_file)
    :ok = make_data_csv_file(features, files.data)
    :ok = make_prediction_config_file(files)

    if cmd_executable?() do
      {_, 0} = exec_lightgbm_prediction(files)
      read_result(files)
    else
      @ng_not_fount_cmd
    end
  end

  defp cmd_executable? do
    if cmd() && System.find_executable(cmd()), do: true, else: false
  end

  defp cmd, do: Application.get_env(:lgbm_ex_cli, :lightgbm_cmd)

  defp exec_lightgbm_train(files, params) do
    {output_log, 0} = System.shell(cmd() <> " config=#{files.config}")
    {num_iterations, eval_value} = fetch_eval(Keyword.get(params, :metric), output_log)

    {:ok, num_iterations, eval_value}
  end

  defp exec_lightgbm_prediction(files) do
    System.shell(cmd() <> " config=#{files.config}")
  end

  defp collect_cli_train_files(workdir) do
    %{
      data: Path.join(workdir, "train.csv"),
      validation: Path.join(workdir, "validation.csv"),
      config: Path.join(workdir, "train_conf.txt"),
      model: Path.join(workdir, "model.txt")
    }
  end

  defp collect_cli_prediction_files(model_file) do
    dir = Path.dirname(model_file)

    %{
      data: Path.join(dir, "prediction.csv"),
      config: Path.join(dir, "prediction_conf.txt"),
      result: Path.join(dir, "prediction_result.tsv"),
      model: model_file
    }
  end

  defp make_data_csv_file(features, labels, filepath) do
    csv = join_data_as_csv(features, labels)
    File.write!(filepath, csv)
  end

  defp make_data_csv_file(features, filepath) do
    csv = join_data_as_csv(features)
    File.write!(filepath, csv)
  end

  defp make_train_config_file(files, params) do
    params_str =
      Enum.map(params, fn {key, value} -> "#{key} = #{value}" end)
      |> Enum.join("\n")

    File.write!(files.config, params_str <> "\n")
  end

  defp make_prediction_config_file(files) do
    params_str = """
    task = prediction
    data = #{files.data}
    input_model = #{files.model}
    output_result = #{files.result}
    """

    File.write!(files.config, params_str <> "\n")
  end

  defp defacto_train_params(files) do
    [
      task: "train",
      data: files.data,
      output_model: files.model,
      label_column: 0,
      saved_feature_importance_type: 1
    ]
  end

  defp parse_config_file(files) do
    File.read!(files.config)
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [k, v] = String.split(row, " = ", trim: true)
      {String.to_atom(k), v}
    end)
  end

  defp join_data_as_csv(features, labels) do
    Enum.zip(features, labels)
    |> Enum.map(fn {feature, label} -> "#{label}," <> join_values(feature, "") end)
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp join_data_as_csv(features) do
    features
    |> Enum.map(& join_values(&1, ""))
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp join_values([only_one], _acc) do
    "#{only_one ||"NA"}"
  end

  defp join_values([head, tail], acc) do
    acc <> "#{head || "NA"},#{tail || "NA"}"
  end

  defp join_values([head | tail], acc) do
    join_values(tail, acc <> "#{head || "NA"},")
  end

  defp fetch_eval(metric, output_log) do
    output_log
    |> String.split("\n")
    |> Enum.reverse()
    |> Enum.find(& String.match?(&1, ~r/Iteration:/))
    |> case do
      nil -> {nil, nil}
      result_log ->
        num_iterations =
          Regex.scan(~r/Iteration:(\d+)/, result_log)
          |> then(fn [[_, matched]] -> String.to_integer(matched) end)
        eval_value =
          Regex.scan(~r/#{metric} : ([\d\.]+)/, result_log)
          |> case do
            [] -> nil
            [[_, matched]] -> String.to_float(matched)
          end
        {num_iterations, eval_value}
    end
  end

  defp read_result(files) do
    files.result
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(& &1 == "")
    |> Enum.map(fn row ->
      String.split(row, "\t")
      |> Enum.map(& String.to_float/1)
    end)
  end
end
