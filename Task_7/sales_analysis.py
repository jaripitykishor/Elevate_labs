import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
import random

def create_database_and_table():
    """Create SQLite database and populate with sample sales data"""
    # Connect to SQLite database (creates file if it doesn't exist)
    conn = sqlite3.connect("sales_data.db")
    cursor = conn.cursor()
    
    # Create sales table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            date TEXT NOT NULL
        )
    ''')
    
    # Sample data for different products
    products = ['Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Headphones', 'Webcam']
    
    # Generate sample sales data
    sample_data = []
    start_date = datetime(2024, 1, 1)
    
    for i in range(100):  # Generate 100 sample records
        product = random.choice(products)
        quantity = random.randint(1, 10)
        price = round(random.uniform(10, 1000), 2)
        date = start_date + timedelta(days=random.randint(0, 365))
        sample_data.append((product, quantity, price, date.strftime('%Y-%m-%d')))
    
    # Insert sample data
    cursor.executemany('''
        INSERT INTO sales (product, quantity, price, date) 
        VALUES (?, ?, ?, ?)
    ''', sample_data)
    
    conn.commit()
    print("✅ Database created and populated with sample data!")
    print(f"📊 Inserted {len(sample_data)} sample sales records")
    conn.close()

def analyze_sales_data():
    """Connect to database and perform sales analysis"""
    print("\n" + "="*50)
    print("🔍 SALES ANALYSIS REPORT")
    print("="*50)
    
    # Connect to the database
    conn = sqlite3.connect("sales_data.db")
    
    print("\n1️⃣ DATABASE CONNECTION:")
    print("✅ Successfully connected to sales_data.db")
    
    # Query 1: Basic sales summary by product
    print("\n2️⃣ SQL QUERY 1: Sales Summary by Product")
    query1 = """
        SELECT 
            product,
            SUM(quantity) AS total_quantity,
            SUM(quantity * price) AS total_revenue,
            COUNT(*) AS total_transactions,
            ROUND(AVG(price), 2) AS avg_price
        FROM sales 
        GROUP BY product
        ORDER BY total_revenue DESC
    """
    
    print("SQL Query:")
    print(query1)
    
    df1 = pd.read_sql_query(query1, conn)
    print("\n📋 RESULTS:")
    print(df1.to_string(index=False))
    
    # Query 2: Monthly sales trends
    print("\n3️⃣ SQL QUERY 2: Monthly Sales Overview")
    query2 = """
        SELECT 
            strftime('%Y-%m', date) AS month,
            COUNT(*) AS transactions,
            SUM(quantity * price) AS monthly_revenue,
            SUM(quantity) AS total_units_sold
        FROM sales 
        GROUP BY strftime('%Y-%m', date)
        ORDER BY month
    """
    
    print("SQL Query:")
    print(query2)
    
    df2 = pd.read_sql_query(query2, conn)
    print("\n📋 RESULTS:")
    print(df2.to_string(index=False))
    
    conn.close()
    
    # Create visualizations
    create_visualizations(df1, df2)
    
    return df1, df2

def create_visualizations(df1, df2):
    """Create bar charts to visualize the sales data"""
    print("\n4️⃣ CREATING VISUALIZATIONS:")
    
    # Create figure with subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
    
    # Chart 1: Revenue by Product
    ax1.bar(df1['product'], df1['total_revenue'], color='skyblue', edgecolor='navy', alpha=0.7)
    ax1.set_title('Total Revenue by Product', fontsize=14, fontweight='bold')
    ax1.set_xlabel('Product', fontweight='bold')
    ax1.set_ylabel('Revenue ($)', fontweight='bold')
    ax1.tick_params(axis='x', rotation=45)
    ax1.grid(axis='y', alpha=0.3)
    
    # Add value labels on bars
    for i, v in enumerate(df1['total_revenue']):
        ax1.text(i, v + max(df1['total_revenue'])*0.01, f'${v:,.0f}', 
                ha='center', va='bottom', fontweight='bold')
    
    # Chart 2: Monthly Revenue Trend
    ax2.bar(df2['month'], df2['monthly_revenue'], color='lightcoral', edgecolor='darkred', alpha=0.7)
    ax2.set_title('Monthly Revenue Trend', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Month', fontweight='bold')
    ax2.set_ylabel('Monthly Revenue ($)', fontweight='bold')
    ax2.tick_params(axis='x', rotation=45)
    ax2.grid(axis='y', alpha=0.3)
    
    # Add value labels on bars
    for i, v in enumerate(df2['monthly_revenue']):
        ax2.text(i, v + max(df2['monthly_revenue'])*0.01, f'${v:,.0f}', 
                ha='center', va='bottom', fontweight='bold', fontsize=8)
    
    plt.tight_layout()
    
    # Save the chart
    plt.savefig("sales_chart.png", dpi=300, bbox_inches='tight')
    print("📈 Bar charts created and saved as 'sales_chart.png'")
    
    # Display the chart
    plt.show()

def main():
    """Main function to execute the complete sales analysis"""
    print("🚀 TASK 7: SQLite Sales Analysis with Python")
    print("="*55)
    
    # Step 1: Create database and populate with data
    create_database_and_table()
    
    # Step 2: Analyze the sales data
    df1, df2 = analyze_sales_data()
    
    # Summary insights
    print("\n5️⃣ KEY INSIGHTS:")
    print("-" * 40)
    
    top_product = df1.iloc[0]
    print(f"🏆 Top Product by Revenue: {top_product['product']}")
    print(f"💰 Revenue: ${top_product['total_revenue']:,.2f}")
    print(f"📦 Units Sold: {top_product['total_quantity']}")
    print(f"🛒 Transactions: {top_product['total_transactions']}")
    
    total_revenue = df1['total_revenue'].sum()
    total_units = df1['total_quantity'].sum()
    print(f"\n📊 OVERALL TOTALS:")
    print(f"💵 Total Revenue: ${total_revenue:,.2f}")
    print(f"📦 Total Units Sold: {total_units}")
    print(f"🛍️ Total Products: {len(df1)}")
    
    print("\n✅ Analysis Complete!")
    print("📁 Files created:")
    print("  - sales_data.db (SQLite database)")
    print("  - sales_chart.png (Visualization)")

if __name__ == "__main__":
    main()
