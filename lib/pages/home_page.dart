import 'package:electricity_payment_auth/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/billing_record_model.dart';
import '../services/database_helper.dart';
import 'billing_entry.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BillingRecordModel> billingItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout logic here
              // Clear user session and navigate back to login page
              AuthenticationService().logout().then((_) {
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(                  
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              });
            },
          ),
        ],
        title: Center(
          child: Text(widget.title, style: TextStyle(fontSize: 18)),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder(
        stream: DatabaseHelper().getStreamBillingRecords(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No billing records found.'));
          }
          return _buildListView(snapshot);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(padding: const EdgeInsets.all(12.0)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        shape: CircleBorder(),
        tooltip: 'Add Electricity Payment Entry',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BillingEntry(
                action: 'add',
                billingRecord: BillingRecordModel(
                  userId: 'U001',
                  month: DateFormat('MMMM yyyy').format(DateTime.now()),
                  units: 0,
                  amount: 0.0,
                  paidStatus: 'Paid',
                ),
              ),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Build the ListView for displaying billing records
  Widget _buildListView(AsyncSnapshot snapshot) {
    billingItems.clear();
    for (var doc in snapshot.data!.docs) {
      billingItems.add(
        BillingRecordModel(
          userId: doc.get('userId'),
          month: doc.get('month'),
          units: doc.get('units') as int,
          amount: doc.get('amount') is int
              ? (doc.get('amount') as int).toDouble()
              : doc.get('amount') as double,
          paidStatus: doc.get('paidStatus'),
          referenceId: doc.id,
        ),
      ); // Update the snapshot data with the model
    }
    // Sort the billing items by month
    billingItems.sort((a, b) {
      // ใช้ DateFormat จากแพ็กเกจ intl เพื่อแปลง String เป็น DateTime
      DateFormat format = DateFormat("MMMM yyyy");

      DateTime dateA = format.parse(a.month);
      DateTime dateB = format.parse(b.month);

      return dateA.compareTo(dateB);
    });

    return ListView.separated(
      itemCount: billingItems.length,
      itemBuilder: (BuildContext context, int index) {
        String titleDate = billingItems[index].month;
        String paidStatusText = billingItems[index].paidStatus == 'Paid'
            ? 'ชำระแล้ว'
            : 'ยังไม่ชำระ';
        String subtitle =
            "หน่วยที่ใช้ ${billingItems[index].units} หน่วย, ${billingItems[index].amount} บาท\n$paidStatusText";
        return ListTile(
          title: Text(
            titleDate,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 14)),
          onTap: () {},
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Colors.grey);
      },
    );
  }
}
