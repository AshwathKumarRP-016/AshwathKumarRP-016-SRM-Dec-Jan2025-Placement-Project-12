package customerorder;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {
	private Connection connection;
    
    public OrderDAO(Connection connection) {
        this.connection = connection;
    }
    
    
    public boolean addOrder(Customer order) throws SQLException {
        String sql = "INSERT INTO orders (customer_name, item, quantity) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, order.getCustomerName());
            stmt.setString(2, order.getItem());
            stmt.setInt(3, order.getQuantity());
            return stmt.executeUpdate() > 0;
        }
    }
    
    
    public List<Customer> getOrdersByCustomer(String customerName) throws SQLException {
        List<Customer> orders = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE customer_name = ? ORDER BY order_date DESC";
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, customerName);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Customer order = new Customer();
                order.setOrderId(rs.getInt("order_id"));
                order.setCustomerName(rs.getString("customer_name"));
                order.setItem(rs.getString("item"));
                order.setQuantity(rs.getInt("quantity"));
                order.setOrderDate(rs.getTimestamp("order_date"));
                orders.add(order);
            }
        }
        return orders;
    }
    
   
    public List<String> getAllItems() throws SQLException {
        List<String> items = new ArrayList<>();
        String sql = "SELECT item_name FROM items ORDER BY category, item_name";
        
        try (Statement stmt = connection.createStatement()) {
            ResultSet rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                items.add(rs.getString("item_name"));
            }
        }
        return items;
    }
    
   
    public boolean itemExists(String itemName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM items WHERE item_name = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, itemName);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }
}
