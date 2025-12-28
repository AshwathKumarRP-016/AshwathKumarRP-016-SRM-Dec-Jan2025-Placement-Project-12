package customerorder;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.w3c.dom.Document;

import java.sql.*;

@SuppressWarnings("serial")
@WebServlet("/OrderServlet")
public class Customerorder extends HttpServlet {
	private Connection connection;
    private OrderDAO orderDAO;
    
    
    @Override
    public void init() throws ServletException {
        try {
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            
            String url = "jdbc:mysql://localhost:3306/orderdb?useSSL=false&serverTimezone=UTC";
            String username = "root";
            String password = "root";
            
            connection = DriverManager.getConnection(url, username, password);
            orderDAO = new OrderDAO(connection);
            
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver not found", e);
        } catch (SQLException e) {
            throw new ServletException("Database connection failed", e);
        }
    }
    
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
    	// In OrderServlet's doGet method:
    	String action = request.getParameter("action");

    	if ("searchOrders".equals(action)) {
    	    String customerName = request.getParameter("customerName");
    	    
    	    try {
    	        List<Customer> orders = orderDAO.getOrdersByCustomer(customerName);
    	        
    	        response.setContentType("text/html");
    	        PrintWriter out = response.getWriter();
    	        
    	        out.println("<!DOCTYPE html>");
    	        out.println("<html>");
    	        out.println("<head><title>Order History</title>");
    	        out.println("<style>");
    	        out.println("body { font-family: Arial; padding: 20px; }");
    	        out.println("table { width: 100%; border-collapse: collapse; }");
    	        out.println("th, td { border: 1px solid #ddd; padding: 8px; }");
    	        out.println("th { background-color: #4CAF50; color: white; }");
    	        out.println("</style>");
    	        out.println("</head>");
    	        out.println("<body>");
    	        out.println("<h2>Order History for: " + escapeHtml(customerName) + "</h2>");
    	        
    	        if (orders.isEmpty()) {
    	            out.println("<p>No orders found for this customer.</p>");
    	        } else {
    	            out.println("<table>");
    	            out.println("<tr><th>Order ID</th><th>Item</th><th>Quantity</th><th>Order Date</th></tr>");
    	            
    	            for (Customer order : orders) {
    	                out.println("<tr>");
    	                out.println("<td>" + order.getOrderId() + "</td>");
    	                out.println("<td>" + escapeHtml(order.getItem()) + "</td>");
    	                out.println("<td>" + order.getQuantity() + "</td>");
    	                out.println("<td>" + order.getOrderDate() + "</td>");
    	                out.println("</tr>");
    	            }
    	            
    	            out.println("</table>");
    	        }
    	        
    	        out.println("<br><a href='order-history.html'>Search Again</a> | ");
    	        out.println("<a href='dashboard.html'>Dashboard</a>");
    	        out.println("</body>");
    	        out.println("</html>");
    	        
    	    } catch (SQLException e) {
    	        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
    	                          "Database error: " + e.getMessage());
    	    }
    	}
        
        
        if (action == null) {
            
            response.sendRedirect("order-form.html");
            return;
        }
        
        switch (action) {
            case "dashboard":
                showDashboard(request, response);
                break;
            case "viewHistory":
                showOrderHistoryForm(request, response);
                break;
            case "getOrders":
                getCustomerOrders(request, response);
                break;
            default:
                response.sendRedirect("order-form.html");
        }
    }
    
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("placeOrder".equals(action)) {
            placeOrder(request, response);
        } else if ("searchOrders".equals(action)) {
            searchCustomerOrders(request, response);
        }
    }
    
    
    private void placeOrder(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
           
            String customerName = request.getParameter("customerName");
            String[] items = request.getParameterValues("items[]");
            String[] quantities = request.getParameterValues("quantities[]");
            String[] customItems = request.getParameterValues("customItems[]");
            String[] customQuantities = request.getParameterValues("customQuantities[]");
            
            
            if (customerName == null || customerName.trim().isEmpty()) {
                throw new IllegalArgumentException("Customer name is required");
            }
            
            
            List<String> orderSummary = new ArrayList<>();
            boolean hasOrders = false;
            
            if (items != null) {
                for (int i = 0; i < items.length; i++) {
                    if (items[i] != null && !items[i].isEmpty() && 
                        quantities[i] != null && !quantities[i].isEmpty()) {
                        int quantity = Integer.parseInt(quantities[i]);
                        if (quantity > 0) {
                            
                            Customer order = new Customer(customerName, items[i], quantity);
                            orderDAO.addOrder(order);
                            orderSummary.add(items[i] + " x " + quantity);
                            hasOrders = true;
                        }
                    }
                }
            }
            
           
            if (customItems != null) {
                for (int i = 0; i < customItems.length; i++) {
                    if (customItems[i] != null && !customItems[i].trim().isEmpty() && 
                        customQuantities[i] != null && !customQuantities[i].isEmpty()) {
                        int quantity = Integer.parseInt(customQuantities[i]);
                        if (quantity > 0) {
                            
                            Customer order = new Customer(customerName, customItems[i].trim(), quantity);
                            orderDAO.addOrder(order);
                            orderSummary.add(customItems[i].trim() + " x " + quantity + " (Custom)");
                            hasOrders = true;
                        }
                    }
                }
            }
            
            if (!hasOrders) {
                throw new IllegalArgumentException("No items selected for order");
            }
            
            
            request.setAttribute("customerName", customerName);
            request.setAttribute("orderSummary", orderSummary);
            request.setAttribute("orderDate", new Date(0));
         
            RequestDispatcher dispatcher = request.getRequestDispatcher("order-summary.html");
            dispatcher.forward(request, response);
            
        } catch (NumberFormatException e) {
            showErrorPage(out, "Invalid quantity. Please enter valid numbers.");
        } catch (IllegalArgumentException e) {
            showErrorPage(out, e.getMessage());
        } catch (SQLException e) {
            showErrorPage(out, "Database error: " + e.getMessage());
        } catch (Exception e) {
            showErrorPage(out, "An unexpected error occurred: " + e.getMessage());
        } finally {
            out.close();
        }
    }
    
  
    private void showDashboard(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            
            List<String> items = orderDAO.getAllItems();
            request.setAttribute("items", items);
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("dashboard.jsp");
            dispatcher.forward(request, response);
            
        } catch (SQLException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                             "Database error: " + e.getMessage());
        }
    }
    
    private void showOrderHistoryForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("order-history.html");
        dispatcher.forward(request, response);
    }
    
    
    private void searchCustomerOrders(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        try {
            String customerName = request.getParameter("customerName");
            
            if (customerName == null || customerName.trim().isEmpty()) {
                throw new IllegalArgumentException("Please enter a customer name");
            }
            
            List<Customer> orders = orderDAO.getOrdersByCustomer(customerName.trim());
            
            
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Order History</title>");
            out.println("<style>");
            out.println(getCommonStyles());
            out.println("table { width: 100%; border-collapse: collapse; margin: 20px 0; }");
            out.println("th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }");
            out.println("th { background-color: #4CAF50; color: white; }");
            out.println("tr:nth-child(even) { background-color: #f2f2f2; }");
            out.println("</style>");
            out.println("</head>");
            out.println("<body>");
            out.println("<div class='container'>");
            out.println("<h2>Order History for: " + escapeHtml(customerName) + "</h2>");
            
            if (orders.isEmpty()) {
                out.println("<p>No orders found for this customer.</p>");
            } else {
                out.println("<table>");
                out.println("<tr><th>Order ID</th><th>Item</th><th>Quantity</th><th>Order Date</th></tr>");
                
                for (Customer order : orders) {
                    out.println("<tr>");
                    out.println("<td>" + order.getOrderId() + "</td>");
                    out.println("<td>" + escapeHtml(order.getItem()) + "</td>");
                    out.println("<td>" + order.getQuantity() + "</td>");
                    out.println("<td>" + order.getOrderDate() + "</td>");
                    out.println("</tr>");
                }
                
                out.println("</table>");
            }
            
            out.println("<div class='button-group'>");
            out.println("<a href='OrderServlet?action=dashboard' class='btn'>Dashboard</a>");
            out.println("<a href='OrderServlet?action=viewHistory' class='btn'>Search Another</a>");
            out.println("</div>");
            out.println("</div>");
            out.println("</body>");
            out.println("</html>");
            
        } catch (IllegalArgumentException e) {
            showErrorPage(out, e.getMessage());
        } catch (SQLException e) {
            showErrorPage(out, "Database error: " + e.getMessage());
        } finally {
            out.close();
        }
    }
    
    private void getCustomerOrders(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            String customerName = request.getParameter("customerName");
            List<Customer> orders = orderDAO.getOrdersByCustomer(customerName);
            
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < orders.size(); i++) {
                Customer order = orders.get(i);
                if (i > 0) json.append(",");
                json.append("{")
                    .append("\"orderId\":").append(order.getOrderId()).append(",")
                    .append("\"item\":\"").append(escapeJson(order.getItem())).append("\",")
                    .append("\"quantity\":").append(order.getQuantity()).append(",")
                    .append("\"date\":\"").append(order.getOrderDate()).append("\"")
                    .append("}");
            }
            json.append("]");
            
            out.println(json.toString());
            
        } catch (SQLException e) {
            out.println("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        } finally {
            out.close();
        }
    }
    
    
    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;");
    }
    
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
    
    private void showErrorPage(PrintWriter out, String message) {
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head><title>Error</title>");
        out.println("<style>" + getCommonStyles() + "</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h2 style='color: red;'>Error</h2>");
        out.println("<p>" + escapeHtml(message) + "</p>");
        out.println("<a href='OrderServlet?action=dashboard' class='btn'>Back to Dashboard</a>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
    
    private String getCommonStyles() {
        return "body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; }" +
               ".container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }" +
               ".btn { display: inline-block; padding: 10px 20px; margin: 10px 5px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; }" +
               ".btn:hover { background-color: #45a049; }" +
               ".button-group { margin-top: 20px; text-align: center; }" +
               "h2 { color: #333; text-align: center; margin-bottom: 30px; }";
    }
    
    
    @Override
    public void destroy() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("Database connection closed successfully.");
            }
        } catch (SQLException e) {
            System.err.println("Error closing database connection: " + e.getMessage());
        }
    }

}
