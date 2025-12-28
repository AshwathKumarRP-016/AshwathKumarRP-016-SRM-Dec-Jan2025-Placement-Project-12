<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order DashBoard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2196F3;
            text-align: center;
            margin-bottom: 40px;
        }
        .dashboard-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .card {
            background: #fff;
            border-radius: 8px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
            border-top: 4px solid #4CAF50;
        }
        .card h3 {
            color: #333;
            margin-bottom: 15px;
        }
        .card p {
            color: #666;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background-color: #2196F3;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        .btn:hover {
            background-color: #0b7dda;
        }
        .btn-secondary {
            background-color: #4CAF50;
        }
        .btn-secondary:hover {
            background-color: #45a049;
        }
        .available-items {
            margin-top: 40px;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 8px;
        }
        .available-items h3 {
            color: #333;
            margin-bottom: 15px;
        }
        .items-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
        }
        .item-tag {
            background-color: #e3f2fd;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 14px;
            color: #1565c0;
        }
        .instructions {
            background-color: #fff8e1;
            padding: 15px;
            border-radius: 8px;
            margin-top: 30px;
            border-left: 4px solid #ffc107;
        }
        .instructions h4 {
            color: #ff9800;
            margin-top: 0;
        }
        .system-info {
            text-align: center;
            margin-top: 40px;
            padding: 20px;
            background-color: #f0f8ff;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Customer Order Main Page</h1>
        
        <div class="dashboard-cards">
            <div class="card">
                <h3>Place New Order</h3>
                <p>Create a new customer order. You can select from available items or add custom items.</p>
                <a href="order-form.html" class="btn">Place Order</a>
            </div>
            
            <div class="card">
                <h3>View Order History</h3>
                <p>Search for a customer's order history by entering their name. View all past orders with details.</p>
                <a href="order-history.jsp" class="btn btn-secondary">View History</a>
            </div>
            
            
        </div>
        
        <div class="available-items" id="available-items">
            <h3>Available Predefined Items</h3>
            <div class="items-grid" id="itemsGrid">
                <!-- Items will be loaded via JavaScript -->
                <span class="item-tag">Loading items...</span>
            </div>
        </div>
        
        <div class="instructions" id="instructions">
            <h4>How to Use the System:</h4>
            <ol>
                <li><strong>Place New Order:</strong> Click "Place Order" to fill out the order form. Add items using the dropdown or custom item fields.</li>
                <li><strong>Order Summary:</strong> After submitting, you'll see an order summary with all items listed.</li>
                <li><strong>View History:</strong> Use "View History" to search for existing customer orders by name.</li>
                <li><strong>Custom Items:</strong> If an item is not in the list, use the "Add Custom Item" button.</li>
                <li><strong>Multiple Items:</strong> Add as many items as needed using the + buttons.</li>
            </ol>
        </div>
        
        <div class="system-info">
            <p>System Status: <span id="systemStatus" style="color: #4CAF50; font-weight: bold;">● Online</span></p>
            
            <p><a href="OrderServlet?action=test" style="color: #2196F3; text-decoration: none;">Test Database Connection</a></p>
        </div>
    </div>

    <script>
        
        document.addEventListener('DOMContentLoaded', function() {
            loadAvailableItems();
            
            
            checkSystemStatus();
        });
        
        function loadAvailableItems() {
            fetch('OrderServlet?action=getItems')
                .then(response => response.json())
                .then(items => {
                    const itemsGrid = document.getElementById('itemsGrid');
                    if (items && items.length > 0) {
                        itemsGrid.innerHTML = '';
                        items.forEach(item => {
                            const tag = document.createElement('span');
                            tag.className = 'item-tag';
                            tag.textContent = item;
                            itemsGrid.appendChild(tag);
                        });
                    } else {
                       
                        const defaultItems = [
                            'Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Headphones',
                            'Notebook', 'Pen', 'Coffee Mug', 'Water Bottle', 'Backpack'
                        ];
                        itemsGrid.innerHTML = '';
                        defaultItems.forEach(item => {
                            const tag = document.createElement('span');
                            tag.className = 'item-tag';
                            tag.textContent = item;
                            itemsGrid.appendChild(tag);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error loading items:', error);
                    
                    const itemsGrid = document.getElementById('itemsGrid');
                    itemsGrid.innerHTML = '';
                    ['Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Headphones'].forEach(item => {
                        const tag = document.createElement('span');
                        tag.className = 'item-tag';
                        tag.textContent = item;
                        itemsGrid.appendChild(tag);
                    });
                });
        }
        
        function checkSystemStatus() {
            fetch('OrderServlet?action=status')
                .then(response => {
                    const statusElement = document.getElementById('systemStatus');
                    if (response.ok) {
                        statusElement.innerHTML = '● Online';
                        statusElement.style.color = '#4CAF50';
                    } else {
                        statusElement.innerHTML = '● Offline';
                        statusElement.style.color = '#f44336';
                    }
                })
                .catch(error => {
                    const statusElement = document.getElementById('systemStatus');
                    statusElement.innerHTML = '● Connection Error';
                    statusElement.style.color = '#ff9800';
                });
        }
    </script>
</body>
</html>