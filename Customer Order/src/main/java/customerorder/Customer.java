package customerorder;

import java.sql.Timestamp;

public class Customer {
	 private int orderId;
	    private String customerName;
	    private String item;
	    private int quantity;
	    private Timestamp orderDate;
	    
	    public Customer() {}
	    
	    public Customer(String customerName, String item, int quantity) {
	        this.customerName = customerName;
	        this.item = item;
	        this.quantity = quantity;
	    }
	    
	    public int getOrderId() { return orderId; }
	    public void setOrderId(int orderId) { this.orderId = orderId; }
	    
	    public String getCustomerName() { return customerName; }
	    public void setCustomerName(String customerName) { this.customerName = customerName; }
	    
	    public String getItem() { return item; }
	    public void setItem(String item) { this.item = item; }
	    
	    public int getQuantity() { return quantity; }
	    public void setQuantity(int quantity) { this.quantity = quantity; }
	    
	    public Timestamp getOrderDate() { return orderDate; }
	    public void setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }
	    
	    @Override
	    public String toString() {
	        return "Order [orderId=" + orderId + ", customerName=" + customerName + 
	               ", item=" + item + ", quantity=" + quantity + ", orderDate=" + orderDate + "]";
	    }
}
