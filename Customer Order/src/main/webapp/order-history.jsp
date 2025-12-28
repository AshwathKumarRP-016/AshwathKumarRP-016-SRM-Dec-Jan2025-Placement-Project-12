<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Database connection parameters
    String dbUrl = "jdbc:mysql://localhost:3306/orderdb";
    String dbUser = "root";
    String dbPass = "root";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String customerName = request.getParameter("customerName");
    List<Map<String, Object>> orders = new ArrayList<>();
    
    if (customerName != null && !customerName.trim().isEmpty()) {
        try {
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            
            
            String sql = "SELECT * FROM orders WHERE customer_name = ? ORDER BY order_date DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerName.trim());
            rs = pstmt.executeQuery();
            
            
            while (rs.next()) {
                Map<String, Object> order = new HashMap<>();
                order.put("orderId", rs.getInt("order_id"));
                order.put("item", rs.getString("item"));
                order.put("quantity", rs.getInt("quantity"));
                order.put("orderDate", rs.getTimestamp("order_date"));
                orders.add(order);
            }
        } catch (Exception e) {
            out.println("<div style='color:red;padding:10px;'>Error: " + e.getMessage() + "</div>");
        } finally {
           
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order History</title>
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
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .search-form {
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 8px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            box-sizing: border-box;
        }
        .search-btn {
            display: block;
            width: 100%;
            padding: 15px;
            background-color: #2196F3;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 18px;
            margin-top: 20px;
        }
        .search-btn:hover {
            background-color: #0b7dda;
        }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #666;
            text-decoration: none;
        }
        .back-link:hover {
            color: #333;
        }
        .results-section {
            margin-top: 40px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #4CAF50;
            color: white;
            position: sticky;
            top: 0;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #e8f5e9;
        }
        .no-results {
            text-align: center;
            padding: 30px;
            background-color: #fff8e1;
            border-radius: 8px;
            color: #ff9800;
            font-size: 18px;
        }
        .customer-name {
            color: #2196F3;
            font-weight: bold;
        }
        .instructions {
            background-color: #e3f2fd;
            padding: 15px;
            border-radius: 8px;
            margin-top: 30px;
            border-left: 4px solid #2196F3;
        }
        .statistics {
            background-color: #e8f5e9;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            text-align: center;
        }
        .stat-item {
            display: inline-block;
            margin: 0 20px;
            padding: 10px 20px;
            background-color: white;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-label {
            font-size: 14px;
            color: #666;
        }
        .stat-value {
            font-size: 24px;
            font-weight: bold;
            color: #4CAF50;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📋 Order History Search</h1>
        
        <div class="search-form">
            <form method="get" action="order-history.jsp">
                <div class="form-group">
                    <label for="customerName">Enter Customer Name:</label>
                    <input type="text" id="customerName" name="customerName" 
                           value="<%= customerName != null ? customerName : "" %>"
                           required placeholder="Enter customer's full name (e.g., Ashwath Kumar)">
                </div>
                
                <button type="submit" class="search-btn">🔍 Search Orders</button>
            </form>
        </div>
        
        <% if (customerName != null && !customerName.trim().isEmpty()) { %>
            <div class="results-section">
                <h2>Order History for: <span class="customer-name"><%= customerName %></span></h2>
                
                <% if (!orders.isEmpty()) { 
                    int totalOrders = orders.size();
                    int totalItems = 0;
                    for (Map<String, Object> order : orders) {
                        totalItems += (Integer) order.get("quantity");
                    }
                %>
                    <div class="statistics">
                        <div class="stat-item">
                            <div class="stat-label">Total Orders</div>
                            <div class="stat-value"><%= totalOrders %></div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-label">Total Items</div>
                            <div class="stat-value"><%= totalItems %></div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-label">First Order</div>
                            <div class="stat-value">
                                <%= ((java.sql.Timestamp) orders.get(orders.size()-1).get("orderDate")).toLocalDateTime().toLocalDate() %>
                            </div>
                        </div>
                    </div>
                    
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Order ID</th>
                                <th>Item Name</th>
                                <th>Quantity</th>
                                <th>Order Date and Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            int counter = 1;
                            for (Map<String, Object> order : orders) { 
                                java.sql.Timestamp timestamp = (java.sql.Timestamp) order.get("orderDate");
                                java.time.LocalDateTime dateTime = timestamp.toLocalDateTime();
                            %>
                                <tr>
                                    <td><%= counter++ %></td>
                                    <td>ORD-<%= order.get("orderId") %></td>
                                    <td><%= order.get("item") %></td>
                                    <td><%= order.get("quantity") %></td>
                                    <td>
                                        <%= dateTime.toLocalDate() %> 
                                        <span style="color: #666; font-size: 12px;">
                                            <%= dateTime.toLocalTime().toString().substring(0, 8) %>
                                        </span>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <div style="text-align: center; margin-top: 20px;">
                        <button onclick="window.print()" class="search-btn" style="background-color: #ff9800; width: auto; display: inline-block; padding: 10px 20px;">
                            🖨️ Print Report
                        </button>
                    </div>
                    
                <% } else { %>
                    <div class="no-results">
                        <p>❌ No orders found for customer: <strong><%= customerName %></strong></p>
                        <p>Please check the spelling or try a different customer name.</p>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="instructions">
                <h3>ℹ️ How to Search Order History:</h3>
                <ul>
                    <li>Enter the exact customer name as used when placing the order</li>
                    <li>The search is case-sensitive</li>
                    <li>You will see all orders placed by that customer</li>
                    <li>Each order will show item, quantity, and order date</li>
                    <li>Example customer name: <strong>Ashwath Kumar</strong></li>
                </ul>
            </div>
        <% } %>
        
        <a href="dashboard.jsp" class="back-link">← Back to Dashboard</a>
        
        <div style="text-align: center; margin-top: 30px; color: #999; font-size: 12px;">
            <p>Order records are stored in MySQL database using JDBC</p>
            <p>Database: orderdb | Table: orders</p>
        </div>
    </div>

    <script>
        
        document.addEventListener('DOMContentLoaded', function() {
            const customerInput = document.getElementById('customerName');
            if (customerInput) {
                customerInput.focus();
                
                
                customerInput.addEventListener('keydown', function(e) {
                    if (e.key === 'Escape') {
                        this.value = '';
                    }
                });
            }
            
            
            const searchForm = document.querySelector('form');
            if (searchForm) {
                searchForm.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter' && e.target.id === 'customerName') {
                        e.preventDefault();
                        this.submit();
                    }
                });
            }
            
            
            const exportBtn = document.createElement('button');
            exportBtn.innerHTML = '📥 Export to CSV';
            exportBtn.style.cssText = 'background-color: #4CAF50; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; margin-left: 10px;';
            exportBtn.onclick = function() {
                exportToCSV();
            };
            
            const printBtn = document.querySelector('button[onclick*="print"]');
            if (printBtn && <%= !orders.isEmpty() %>) {
                printBtn.parentNode.appendChild(exportBtn);
            }
            
            function exportToCSV() {
                let csv = 'Order ID,Item,Quantity,Order Date\n';
                <% for (Map<String, Object> order : orders) { 
                    java.sql.Timestamp timestamp = (java.sql.Timestamp) order.get("orderDate");
                    java.time.LocalDateTime dateTime = timestamp.toLocalDateTime();
                %>
                    csv += 'ORD-<%= order.get("orderId") %>,"<%= order.get("item") %>",<%= order.get("quantity") %>,"<%= dateTime.toString() %>"\n';
                <% } %>
                
                const blob = new Blob([csv], { type: 'text/csv' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                
                // Get customer name from JSP variable
                <% 
                String downloadFilename = "order_history";
                if (customerName != null && !customerName.trim().isEmpty()) {
                    // Clean the filename using Java's replaceAll
                    downloadFilename += "_" + customerName.replaceAll("[^a-zA-Z0-9]", "_");
                }
                downloadFilename += ".csv";
                %>
                
                a.download = '<%= downloadFilename %>';
                
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
            }
        });
    </script>
</body>
</html>