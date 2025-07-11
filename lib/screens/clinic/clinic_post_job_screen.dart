

import 'package:flutter/material.dart';
import '../../models/job.dart';
import '../../services/job_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClinicPostJobScreen extends StatefulWidget {
  static const routeName = '/clinic-post-job';
  const ClinicPostJobScreen({Key? key}) : super(key: key);

  @override
  _ClinicPostJobScreenState createState() => _ClinicPostJobScreenState();
}

class _ClinicPostJobScreenState extends State<ClinicPostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clinicNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  DateTime? _start;
  DateTime? _end;
  bool _loading = false;
  String? _error;

  Future<void> _pickDate(BuildContext ctx, bool isStart) async {
    final initial = isStart ? (_start ?? DateTime.now()) : (_end ?? _start ?? DateTime.now());
    final first = isStart ? DateTime.now() : (_start ?? DateTime.now());
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (isStart) {
        setState(() => _start = picked);
      } else {
        setState(() => _end = picked);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _start == null || _end == null) {
      setState(() => _error = 'Please fill in all fields and select dates.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _error = 'You must be signed in to post a shift.');
        return;
      }
      final job = Job(
        id: '',
        clinicId: user.uid,
        clinicName: _clinicNameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        start: _start!,
        end: _end!,
        rate: double.parse(_rateCtrl.text.trim()),
      );
      await JobService().createJob(job);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to post shift: $e');
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _clinicNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final width = MediaQuery.of(ctx).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Post a New Shift')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _clinicNameCtrl,
                decoration: const InputDecoration(labelText: 'Clinic Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Shift Description'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateCtrl,
                decoration: const InputDecoration(labelText: 'Rate (\$/hr)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  return n == null ? 'Enter a valid number' : null;
                },
              ),
              const SizedBox(height: 24),
              ListTile(
                title: Text(_start == null ? 'Select Start Date' : 'Start: ${_start!.toLocal().toShortDateString()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(ctx, true),
              ),
              ListTile(
                title: Text(_end == null ? 'Select End Date' : 'End: ${_end!.toLocal().toShortDateString()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(ctx, false),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Post Shift'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper extension to format DateTime
extension on DateTime {
  String toShortDateString() {
    return '${this.month}/${this.day}/${this.year}';
  }
}