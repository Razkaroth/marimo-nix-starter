import marimo

__generated_with = "0.13.15"
app = marimo.App(width="medium")

@app.cell
def setup():
    import marimo as mo
    import numpy as np
    import pandas as pd
    return


@app.cell
def _():
    sample_data = np.random.randn(100, 100)
    sample_data = pd.DataFrame({
        "A": np.random.randn(100),
        "B": np.random.randn(100),
        "C": np.random.randn(100),
        "D": np.random.randn(100),
        "E": np.random.randn(100),
        "F": np.random.randn(100),
    })
    mo.ui.dataframe(sample_data)
    return sample_data



if __name__ == "__main__":
    app.run()
