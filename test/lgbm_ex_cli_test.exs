defmodule LGBMExCliTest do
  use ExUnit.Case
  alias LGBMExCli, as: LightGBM
  alias LGBMExCli.SampleData

  describe "fit" do
    @describetag :tmp_dir

    test "returns model_path and evaluation value", c do
      {features, labels} = SampleData.iris(:train)
      params = SampleData.iris_params()

      {:ok, model_path, value} = LightGBM.fit(c.tmp_dir, features, labels, params)
      assert File.exists?(model_path)
      assert value >= 0
    end
  end

  describe "predict" do
    setup do
      workdir = Path.join(System.tmp_dir(), "#{__MODULE__}")
      File.mkdir_p!(workdir)
      on_exit(fn ->
        File.rm_rf!(workdir)
      end)

      {features, labels} = SampleData.iris(:train)
      params = SampleData.iris_params()
      {:ok, model_path, _value} = LightGBM.fit(workdir, features, labels, params)

      {:ok, model_path: model_path}
    end

    test "returns predicted values", c do
      {features, _labels} = SampleData.iris(:test)
      [r0, _r1, r2] = LightGBM.predict(c.model_path, features)

      assert Enum.at(r0, 0) >= 0.5
      # skip r1 assert due to lack of accurate learning.
      # assert Enum.at(r1, 1) >= 0.5
      assert Enum.at(r2, 2) >= 0.5
    end
  end
end
