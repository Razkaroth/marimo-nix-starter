import marimo

__generated_with = "0.13.15"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    import pandas as pd
    import numpy as np
    import plotly.express as px
    return mo, np, pd, px


@app.cell
def _(mo):
    mo.md(
        r"""
    # Welcome to the Data App

    This is the main dashboard for our data application. Navigate between pages to explore different features:

    - **Dashboard**: View analytics and metrics [Dashboard](/dashboard)
    - **Data Explorer**: Explore and analyze datasets
    """
    )
    return


@app.cell
def _(mo, np, pd, px):
    # Sample data visualization
    data = pd.DataFrame({
        'x': np.random.randn(100),
        'y': np.random.randn(100),
        'category': np.random.choice(['A', 'B', 'C'], 100)
    })

    chart = mo.ui.plotly(
        px.scatter(data, x='x', y='y', title='Sample Data Visualization')
    )

    mo.md(f"""
    ## Sample Visualization
    {chart}
    """)
    return


@app.cell
def _(mo):
    mo.md("""Navigate to other pages using the URL paths: `/dashboard` for analytics.""")
    return


if __name__ == "__main__":
    app.run()
