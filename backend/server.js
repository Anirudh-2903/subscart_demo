const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: '*' // Allow all origins for development
}));
app.use(bodyParser.json());
app.use(express.static('public'));

// Sample data
let deliveries = [
  {
    id: uuidv4(),
    name: "Grilled Chicken With Steamed Vegetables",
    description: "Enjoy a wholesome meal with perfectly grilled chicken",
    calories: 304,
    protein: 36,
    fat: 8,
    carbs: 15,
    image: "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=150&h=150&fit=crop",
    deliveryDate: "2025-07-22",
    timeSlot: "14:00",
    deliveryType: "Delivery",
    location: "Subscart",
    status: "scheduled"
  },
  {
    id: uuidv4(),
    name: "Mediterranean Salmon Bowl",
    description: "Fresh salmon with quinoa and Mediterranean vegetables",
    calories: 425,
    protein: 32,
    fat: 18,
    carbs: 28,
    image: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=150&h=150&fit=crop",
    deliveryDate: "2025-07-22",
    timeSlot: "18:00",
    deliveryType: "Delivery",
    location: "Downtown Hub",
    status: "scheduled"
  },
  {
    id: uuidv4(),
    name: "Thai Green Curry",
    description: "Aromatic thai curry with jasmine rice",
    calories: 380,
    protein: 24,
    fat: 14,
    carbs: 42,
    image: "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=150&h=150&fit=crop",
    deliveryDate: "2025-07-23",
    timeSlot: "12:00",
    deliveryType: "Delivery",
    location: "Subscart",
    status: "scheduled"
  },
  {
    id: uuidv4(),
    name: "Quinoa Power Bowl",
    description: "Nutritious bowl with quinoa, avocado, and chickpeas",
    calories: 365,
    protein: 18,
    fat: 16,
    carbs: 48,
    image: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=150&h=150&fit=crop",
    deliveryDate: "2025-07-23",
    timeSlot: "19:00",
    location: "Mall Center",
    deliveryType: "Delivery",
    status: "scheduled"
  },
  {
    id: uuidv4(),
    name: "BBQ Pulled Pork Sandwich",
    description: "Slow-cooked pulled pork with coleslaw",
    calories: 520,
    protein: 28,
    fat: 22,
    carbs: 45,
    image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=150&h=150&fit=crop",
    deliveryDate: "2025-07-24",
    timeSlot: "13:00",
    location: "Downtown Hub",
    deliveryType: "Delivery",
    status: "scheduled"
  }
];

const timeSlots = [
  "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", 
  "15:00", "16:00", "17:00", "18:00", "19:00", "20:00"
];

const locations = [
  { id: 1, name: "Subscart", address: "Main Delivery Center" },
  { id: 2, name: "Downtown Hub", address: "Downtown Location" },
  { id: 3, name: "Mall Center", address: "Shopping Mall Pickup" }
];

// Routes

// Get all deliveries for a specific date
app.get('/api/deliveries', (req, res) => {
  const { date, location, timeSlot } = req.query;
  let filteredDeliveries = deliveries;

  res.json({
    success: true,
    data: filteredDeliveries
  });
});

// Add endpoint to get next available slot

// Get available time slots
app.get('/api/time-slots', (req, res) => {
  const { date } = req.query;
  const currentDate = new Date();
  const selectedDate = new Date(date);

  let availableSlots = timeSlots;

  // If it's today, filter out past time slots
  if (selectedDate.toDateString() === currentDate.toDateString()) {
    const currentHour = currentDate.getHours();
    availableSlots = timeSlots.filter(slot => {
      const slotHour = parseInt(slot.split(':')[0]);
      return slotHour > currentHour;
    });
  }

  res.json({
    success: true,
    data: availableSlots
  });
});

// Get locations
app.get('/api/locations', (req, res) => {
  res.json({
    success: true,
    data: locations
  });
});

// Reschedule delivery
// Update the reschedule endpoint to handle bulk rescheduling
app.put('/api/deliveries/reschedule', (req, res) => {
  const { date, timeSlot, location } = req.body;

  // Validate date is not in the past
  const selectedDate = new Date(date);
  const currentDate = new Date();
  currentDate.setHours(0, 0, 0, 0);

  if (selectedDate < currentDate) {
    return res.status(400).json({
      success: false,
      message: 'Cannot reschedule to a past date'
    });
  }

  // If it's today, validate time slot
  if (selectedDate.toDateString() === currentDate.toDateString()) {
    const currentHour = new Date().getHours();
    const slotHour = parseInt(timeSlot.split(':')[0]);

    if (slotHour <= currentHour) {
      return res.status(400).json({
        success: false,
        message: 'Cannot reschedule to a past time slot'
      });
    }
  }

  // Find deliveries for the current date
  const currentDateString = new Date().toISOString().split('T')[0];
  const deliveriesToReschedule = deliveries.filter(
    d => d.deliveryDate === currentDateString
  );

  // Reschedule all matching deliveries
  const rescheduledDeliveries = deliveriesToReschedule.map(delivery => {
    delivery.deliveryDate = date;
    delivery.timeSlot = timeSlot;
    if (location) {
      delivery.location = location;
    }
    return delivery;
  });

  res.json({
    success: true,
    data: rescheduledDeliveries,
    message: 'Deliveries rescheduled successfully'
  });
});
// Skip delivery
app.put('/api/deliveries/:id/skip', (req, res) => {
  const { id } = req.params;

  const deliveryIndex = deliveries.findIndex(d => d.id === id);

  if (deliveryIndex === -1) {
    return res.status(404).json({
      success: false,
      message: 'Delivery not found'
    });
  }

  res.json({
    success: true,
    data: deliveries[deliveryIndex],
    message: 'Delivery skipped successfully'
  });
});

// Swap delivery positions
app.put('/api/deliveries/:id/swap', (req, res) => {
  const { id } = req.params;
  const { targetId } = req.body;

  const deliveryIndex = deliveries.findIndex(d => d.id === id);
  const targetIndex = deliveries.findIndex(d => d.id === targetId);

  if (deliveryIndex === -1 || targetIndex === -1) {
    return res.status(404).json({
      success: false,
      message: 'Delivery not found'
    });
  }

  res.json({
    success: true,
    data: [deliveries[deliveryIndex], deliveries[targetIndex]],
    message: 'Deliveries swapped successfully'
  });
});

// Move delivery to different position
app.put('/api/deliveries/:id/move', (req, res) => {
  const { id } = req.params;
  const { direction } = req.body; // 'up' or 'down'

  const deliveryIndex = deliveries.findIndex(d => d.id === id);

  if (deliveryIndex === -1) {
    return res.status(404).json({
      success: false,
      message: 'Delivery not found'
    });
  }

  let targetIndex;
  if (direction === 'up' && deliveryIndex > 0) {
    targetIndex = deliveryIndex - 1;
  } else if (direction === 'down' && deliveryIndex < deliveries.length - 1) {
    targetIndex = deliveryIndex + 1;
  } else {
    return res.status(400).json({
      success: false,
      message: 'Cannot move delivery in that direction'
    });
  }

  // Swap positions
  const temp = deliveries[deliveryIndex];
  deliveries[deliveryIndex] = deliveries[targetIndex];
  deliveries[targetIndex] = temp;

  res.json({
    success: true,
    data: deliveries,
    message: 'Delivery moved successfully'
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'Server is running!' });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});