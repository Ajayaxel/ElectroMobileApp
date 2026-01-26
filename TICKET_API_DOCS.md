# Ticket API Documentation

This document describes the ticket creation endpoint and the request/response structure for Onecharge.

## Create Ticket

Create a new service request (ticket) for a vehicle.

- **Endpoint**: `/customer/tickets`
- **Method**: `POST` (Multipart/Form-Data)
- **Authentication**: Bearer Token required

### Request Parameters (Form-Data)

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `issue_category_id` | Integer | Yes | ID of the issue category (e.g., 1 for Charging Station, 6 for Other) |
| `issue_category_sub_type_id` | Integer | No | ID of the sub-type (Charge Unit) |
| `vehicle_type_id` | Integer | Yes | ID of the vehicle type |
| `brand_id` | Integer | Yes | ID of the vehicle brand |
| `model_id` | Integer | Yes | ID of the vehicle model |
| `number_plate` | String | Yes | Vehicle license plate number |
| `description` | String | No | Description of the issue (Required for 'Other' category) |
| `location` | String | Yes | Human-readable address string |
| `latitude` | Double | Yes | Latitude of the location |
| `longitude` | Double | Yes | Longitude of the location |
| `attachments[]` | File(s) | No | Images or video files related to the issue |
| `redeem_code` | String | No | Discount/Redeem code |
| `payment_method` | String | No | `cod` for Cash on Delivery, omitted or `null` for Online Payment |
| `booking_type` | String | Yes | `instant` for immediate booking, `scheduled` for future date/time |
| `scheduled_at` | String | No | Date and time for scheduled booking. Format: `YYYY-MM-DD HH:mm:ss`. Required if `booking_type` is `scheduled`. |

### Request Example (JSON representation of Form-Data)

#### Instant Booking
```json
{
    "issue_category_id": 1,
    "booking_type": "instant",
    "scheduled_at": null,
    "location": "Union Square, San Francisco",
    "latitude": 37.7879,
    "longitude": -122.4074,
    "vehicle_type_id": 1,
    "brand_id": 5,
    "model_id": 12,
    "number_plate": "DXB-12345"
}
```

#### Scheduled Booking
```json
{
    "issue_category_id": 1,
    "booking_type": "scheduled",
    "scheduled_at": "2026-03-25 14:00:00",
    "location": "Union Square, San Francisco",
    "latitude": 37.7879,
    "longitude": -122.4074,
    "vehicle_type_id": 1,
    "brand_id": 5,
    "model_id": 12,
    "number_plate": "DXB-12345"
}
```

### Response Structure

The API returns a JSON response:

| Field | Type | Description |
| :--- | :--- | :--- |
| `success` | Boolean | Whether the request was successful |
| `message` | String | Status message from the server |
| `data` | Object | Response data containing ticket details or payment info |
| `data.payment_required` | Boolean | Whether payment is needed to finalize the ticket |
| `data.payment_url` | String | URL to the payment gateway (if applicable) |
| `data.intention_id` | String | Unique ID for the payment transaction |
| `data.ticket` | Object | The created ticket object (if no payment or after payment) |

---
Documentation created on January 26, 2026.
