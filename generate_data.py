"""
Generate realistic e-commerce order data for SQL analytics project
This creates a SQL file with INSERT statements for orders and order_items
"""

import random
from datetime import datetime, timedelta

# Configuration
NUM_ORDERS = 2000
OUTPUT_FILE = '03_generate_orders.sql'

# Customer and product ranges
CUSTOMER_IDS = list(range(1, 101))
PRODUCT_IDS = list(range(1, 41))
ORDER_STATUSES = ['Completed', 'Completed', 'Completed', 'Completed', 'Completed', 
                  'Completed', 'Completed', 'Processing', 'Cancelled', 'Returned']

# Date range: January 2023 to December 2024
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2024, 12, 31)

def random_date(start, end):
    """Generate a random date between start and end"""
    delta = end - start
    random_days = random.randint(0, delta.days)
    return start + timedelta(days=random_days)

def generate_orders():
    """Generate random order data"""
    orders = []
    order_items = []
    order_item_id = 1
    
    for order_id in range(1, NUM_ORDERS + 1):
        customer_id = random.choice(CUSTOMER_IDS)
        order_date = random_date(START_DATE, END_DATE)
        order_status = random.choice(ORDER_STATUSES)
        shipping_cost = round(random.uniform(5.0, 25.0), 2)
        
        orders.append({
            'order_id': order_id,
            'customer_id': customer_id,
            'order_date': order_date.strftime('%Y-%m-%d'),
            'order_status': order_status,
            'shipping_cost': shipping_cost
        })
        
        # Generate 1-5 items per order
        num_items = random.randint(1, 5)
        products_in_order = random.sample(PRODUCT_IDS, num_items)
        
        for product_id in products_in_order:
            quantity = random.randint(1, 3)
            # Product prices (matching the products table)
            product_prices = {
                1: 149.99, 2: 399.99, 3: 49.99, 4: 79.99, 5: 129.99,
                6: 29.99, 7: 79.99, 8: 199.99, 9: 139.99, 10: 89.99,
                11: 89.99, 12: 249.99, 13: 39.99, 14: 69.99, 15: 49.99,
                16: 34.99, 17: 199.99, 18: 599.99, 19: 79.99, 20: 59.99,
                21: 24.99, 22: 34.99, 23: 14.99, 24: 19.99, 25: 29.99,
                26: 44.99, 27: 79.99, 28: 69.99, 29: 24.99, 30: 89.99,
                31: 99.99, 32: 79.99, 33: 39.99, 34: 119.99, 35: 149.99,
                36: 29.99, 37: 19.99, 38: 24.99, 39: 44.99, 40: 34.99
            }
            
            unit_price = product_prices[product_id]
            # 30% chance of discount (5-20% off)
            discount_amount = round(unit_price * quantity * random.uniform(0.05, 0.20), 2) if random.random() < 0.3 else 0
            
            order_items.append({
                'order_item_id': order_item_id,
                'order_id': order_id,
                'product_id': product_id,
                'quantity': quantity,
                'unit_price': unit_price,
                'discount_amount': discount_amount
            })
            order_item_id += 1
    
    return orders, order_items

def write_sql_file(orders, order_items):
    """Write orders and order_items to SQL file"""
    with open(OUTPUT_FILE, 'w') as f:
        f.write("-- Generated Orders and Order Items Data\n")
        f.write("-- This file contains realistic transactional data for analytics\n\n")
        
        # Write orders
        f.write("-- Insert Orders\n")
        f.write("INSERT INTO orders (order_id, customer_id, order_date, order_status, shipping_cost) VALUES\n")
        
        for i, order in enumerate(orders):
            values = f"({order['order_id']}, {order['customer_id']}, '{order['order_date']}', '{order['order_status']}', {order['shipping_cost']})"
            if i < len(orders) - 1:
                f.write(f"{values},\n")
            else:
                f.write(f"{values};\n\n")
        
        # Write order items in batches (SQLite has a limit on number of rows per INSERT)
        f.write("-- Insert Order Items\n")
        batch_size = 500
        for batch_start in range(0, len(order_items), batch_size):
            batch = order_items[batch_start:batch_start + batch_size]
            f.write("INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_amount) VALUES\n")
            
            for i, item in enumerate(batch):
                values = f"({item['order_item_id']}, {item['order_id']}, {item['product_id']}, {item['quantity']}, {item['unit_price']}, {item['discount_amount']})"
                if i < len(batch) - 1:
                    f.write(f"{values},\n")
                else:
                    f.write(f"{values};\n\n")

if __name__ == "__main__":
    print("Generating e-commerce order data...")
    orders, order_items = generate_orders()
    
    print(f"Generated {len(orders)} orders")
    print(f"Generated {len(order_items)} order items")
    
    write_sql_file(orders, order_items)
    print(f"SQL file written to: {OUTPUT_FILE}")
    print("\nSummary:")
    print(f"- Date range: 2023-01-01 to 2024-12-31")
    print(f"- Customers: 100")
    print(f"- Products: 40")
    print(f"- Avg items per order: {len(order_items) / len(orders):.1f}")
