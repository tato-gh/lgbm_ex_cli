defmodule LGBMExCli.SampleData do
  @moduledoc """
  Sample data for testing.
  """

  @doc """
  Clipping of iris dataset.
  """
  def iris(:train) do
    {
      [
        [5.1, 3.5, 1.4, 0.2],
        [4.9, 3.0, 1.4, 0.2],
        [4.7, 3.2, 1.3, 0.2],
        [4.6, 3.1, 1.5, 0.2],
        [5.0, 3.6, 1.4, 0.2],
        [7.0, 3.2, 4.7, 1.4],
        [6.4, 3.2, 4.5, 1.5],
        [6.9, 3.1, 4.9, 1.5],
        [5.5, 2.3, 4.0, 1.3],
        [6.5, 2.8, 4.6, 1.5],
        [6.3, 3.3, 6.0, 2.5],
        [5.8, 2.7, 5.1, 1.9],
        [7.1, 3.0, 5.9, 2.1],
        [6.3, 2.9, 5.6, 1.8],
        [6.5, 3.0, 5.8, 2.2]
      ],
      [
        0, 0, 0, 0, 0,
        1, 1, 1, 1, 1,
        2, 2, 2, 2, 2
      ]
    }
  end

  def iris(:test) do
    {
      [
        [5.4, 3.9, 1.7, 0.4],
        [5.7, 2.8, 4.5, 1.3],
        [7.6, 3.0, 6.6, 2.1]
      ],
      [0 , 1, 2]
    }
  end

  def iris_params(params \\ []) do
    [
      objective: "multiclass",
      metric: "multi_logloss",
      num_class: 3,
      num_iterations: 10,
      num_leaves: 5,
      min_data_in_leaf: 1,
      force_row_wise: true,
      seed: 42
    ]
    |> Keyword.merge(params)
  end
end
