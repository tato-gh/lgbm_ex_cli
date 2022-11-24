# LGBMExCli

LightGBM CLI wrapper on Elixir.

Functions

- `fit/4`: for train
- `predict/2`: for prediction
- `refit/2`: for parameters exploration

Sample code

```elixir
alias LGBMExCli, as: LightGBM

# Preparation

Application.put_env(:lgbm_ex_cli, :lightgbm_cmd, <microsoft/LightGBM command path>)
workdir = Path.join(System.tmp_dir(), "lightgbm")
File.mkdir_p(workdir)

features_train = [
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
]
features_validation = [
  [5.4, 3.9, 1.7, 0.4],
  [5.7, 2.8, 4.5, 1.3],
  [7.6, 3.0, 6.6, 2.1]
]

labels_train = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2]
labels_validation = [0, 1, 2]


# Fit

{:ok, model_file, _num_iterations, _eval_value} =
  LightGBM.fit(
    workdir,
    {features_train, features_validation},
    {labels_train, labels_validation},
    [
      objective: "multiclass",
      metric: "multi_logloss",
      num_class: 3,
      num_iterations: 100,
      num_leaves: 5,
      min_data_in_leaf: 1,
      early_stopping_round: 2
    ]
  )

# Prediction

results = LightGBM.predict(model_file, features_validation)

# Refit

{:ok, _model_file, _num_iterations, _eval_value} =
  LightGBM.refit(workdir, [
    max_depth: 3,
    min_data_in_leaf: 1,
    early_stopping_round: 2
  ])

```


**NOTE**

- Beta version / Not stable
- see [LGBMExCapi](https://github.com/tato-gh/lgbm_ex_capi) to predict small size data.


## Installation

**microsoft/LightGBM**

- Refs: [LightGBM Installation Guide](https://lightgbm.readthedocs.io/en/latest/Installation-Guide.html#linux)


**Library**

```
def deps do
  [
    {:lgbm_ex_cli, "0.1.0", git: "https://github.com/tato-gh/lgbm_ex_cli"}
  ]
end
```


**Config**

```elixir
config :lgbm_ex_cli, lightgbm_cmd: <microsoft/LightGBM CLI command path>
```

