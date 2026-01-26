import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_bloc.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_event.dart';
import 'package:onecharge/logic/blocs/ticket/ticket_state.dart';
import 'package:onecharge/models/ticket_model.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const BookingDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final invoice = ticket.invoice;
    final driverName = ticket.driver?.name ?? '-';
    final orderId = ticket.ticketId;
    final serviceName = ticket.issueCategory?.name ?? '-';
    final location = ticket.location ?? '-';

    String bookingTime = '-';
    // Show scheduled time for scheduled bookings, creation time for instant
    String? rawTime = ticket.bookingType == 'scheduled'
        ? ticket.scheduledAt
        : ticket.createdAt;

    if (rawTime != null && rawTime.isNotEmpty) {
      try {
        String dateStr = rawTime;
        // If string doesn't have timezone info, assume it's UTC from server
        if (!dateStr.contains('Z') && !dateStr.contains('+')) {
          dateStr = '${dateStr.replaceFirst(' ', 'T')}Z';
        }
        final dt = DateTime.parse(dateStr).toLocal();
        bookingTime = DateFormat('hh:mm a').format(dt);
      } catch (_) {
        bookingTime = rawTime;
      }
    }

    final totalAmount = invoice != null
        ? '${invoice.currency} ${invoice.totalAmount.toStringAsFixed(2)}'
        : '-';
    final trnNumber = invoice?.invoiceNumber != null
        ? '#${invoice!.invoiceNumber}'
        : '-';
    final paymentMethod = ticket.paymentMethod ?? '-';
    final paymentStatus = (ticket.status ?? 'Pending');

    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is InvoiceDownloadLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading invoice...'),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is InvoiceDownloadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice downloaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          OpenFile.open(state.filePath);
        } else if (state is InvoiceDownloadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.file_download_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                context.read<TicketBloc>().add(
                  DownloadInvoiceRequested(ticket.id),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          title: const Text(
            'Detail Page',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Details'),
              _buildDetailRow('Agent Name', driverName),
              _buildDetailRow('Order ID', orderId),
              _buildDetailRow('Model', '-'),
              _buildDetailRow('Number', '-'),
              const SizedBox(height: 10),
              _buildSectionHeader('Details'),
              _buildDetailRow('Service', serviceName),
              _buildDetailRow('Booking Time', bookingTime),
              _buildDetailRow(
                'Booking Type',
                ticket.bookingType != null
                    ? ticket.bookingType![0].toUpperCase() +
                          ticket.bookingType!.substring(1)
                    : '-',
              ),
              _buildDetailRow('Location', location, isMultiLine: true),
              _buildDetailRow('Number', '-'),
              const SizedBox(height: 10),
              _buildSectionHeader('Payment Details'),
              _buildDetailRow('Total Amount', totalAmount),
              _buildDetailRow('TRN Number', trnNumber),
              _buildDetailRow(
                'Payment Method',
                paymentMethod,
                isMultiLine: true,
              ),
              _buildDetailRow('Payment Status', paymentStatus),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF7F7F7),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lufga',
          color: Color(0xFF4A4D54),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lufga',
                color: Color(0xFF4A4D54),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Lufga',
                color: Color(0xFF23262F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
