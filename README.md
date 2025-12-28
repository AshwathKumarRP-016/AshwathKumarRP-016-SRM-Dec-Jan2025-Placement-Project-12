# Customer Order Placement System

## 📋 Project Overview
A complete Servlet + JDBC web application for customer order management where customers can place orders, view order history, and administrators can track all orders through a dashboard.

## 🎯 Features

### 1. **Order Placement**
- Customer-friendly order form with predefined items
- Add custom items dynamically
- Multiple item selection with quantities
- Real-time form validation

### 2. **Order Management**
- Automatic order summary generation
- Unique order ID assignment
- Database persistence using MySQL
- Order confirmation with printable receipt

### 3. **Order History**
- Search orders by customer name
- View complete order history with details
- Export order data to CSV
- Print-friendly order reports

### 4. **Dashboard**
- Centralized system control panel
- Quick access to all features
- System status monitoring
- Database connection testing


## 📁 Project Structure

```
Customer_Order/
├── src/main/java/customerorder/
│   ├── OrderServlet.java      # Main servlet controller
│   ├── OrderDAO.java          # Database operations
│   └── Order.java             # Data model
├── src/main/webapp/
│   ├── order-form.html        # Order placement form
│   ├── order-summary.html     # Order confirmation
│   ├── order-history.jsp      # Order search and display
│   ├── dashboard.html         # System dashboard
│   └── WEB-INF/
│       ├── web.xml            # Deployment descriptor
│       └── lib/               # JDBC driver
└── database_setup.sql         # Database schema
```


## 📊 Key Features in Detail

### ✅ Order Placement Process
1. Customer enters name
2. Selects items from dropdown or adds custom items
3. Specifies quantities
4. Submits order to servlet
5. Receives confirmation with order summary

## 📱 User Flow

1. **Customer** → Places order via form → Gets confirmation
2. **Admin** → Views dashboard → Manages orders
3. **Customer Service** → Searches order history → Assists customers

