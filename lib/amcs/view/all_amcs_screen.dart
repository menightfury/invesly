import 'package:flutter/material.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:http/http.dart' as http;

class AllAmcsScreen extends StatefulWidget {
  const AllAmcsScreen({super.key});

  @override
  State<AllAmcsScreen> createState() => _AllAmcsScreenState();
}

class _AllAmcsScreenState extends State<AllAmcsScreen> {
  late Future<List<InveslyAmc>> future;

  @override
  void initState() {
    super.initState();
    future = AmcRepository.instance.getAllAmcs();
    http.Client();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All AMCs')),
      body: FutureBuilder<List<InveslyAmc>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No AMCs found.'));
          } else {
            final amcs = snapshot.data!;
            return ListView.builder(
              itemCount: amcs.length,
              itemBuilder: (context, index) {
                final amc = amcs[index];
                return ListTile(
                  tileColor: index.isEven ? Colors.grey[300] : null,
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  title: Text(amc.name),
                  subtitle: Text('ID: ${amc.id}, tags: ${amc.tag?.toJson() ?? 'N/A'}'),
                  trailing: Text(amc.genre?.name ?? 'Genre: N/A'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
