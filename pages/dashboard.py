import marimo

__generated_with = "0.13.15"
app = marimo.App(width="medium")


@app.cell
def __():
    import marimo as mo
    import pandas as pd
    import numpy as np
    import plotly.express as px
    return mo, np, pd, px


@app.cell
def __(mo):
    mo.md(
        r"""
        # Analytics Dashboard
        
        This page contains various analytics and metrics for monitoring your data and application performance.
        """
    )
    return


@app.cell
def __(mo, np, pd, px):
    # Generate sample metrics data
    dates = pd.date_range('2024-01-01', periods=30, freq='D')
    metrics_data = pd.DataFrame({
        'date': dates,
        'users': np.random.randint(100, 1000, 30),
        'revenue': np.random.uniform(1000, 5000, 30),
        'conversion_rate': np.random.uniform(0.02, 0.08, 30)
    })
    
    # Create interactive charts
    users_chart = px.line(metrics_data, x='date', y='users', title='Daily Active Users')
    revenue_chart = px.bar(metrics_data, x='date', y='revenue', title='Daily Revenue')
    
    mo.md(f"""
    ## Key Metrics
    
    ### User Analytics
    {mo.ui.plotly(users_chart)}
    
    ### Revenue Analytics  
    {mo.ui.plotly(revenue_chart)}
    """)
    return dates, metrics_data, revenue_chart, users_chart


@app.cell
def __(metrics_data, mo):
    # Summary statistics
    total_users = metrics_data['users'].sum()
    avg_revenue = metrics_data['revenue'].mean()
    avg_conversion = metrics_data['conversion_rate'].mean()
    
    mo.md(f"""
    ## Summary Statistics
    
    - **Total Users**: {total_users:,}
    - **Average Daily Revenue**: ${avg_revenue:,.2f}
    - **Average Conversion Rate**: {avg_conversion:.2%}
    """)
    return avg_conversion, avg_revenue, total_users


@app.cell
def __(mo):
    mo.md("Return to [Home](/) or explore other sections of the application.")
    return


if __name__ == "__main__":
    app.run() 