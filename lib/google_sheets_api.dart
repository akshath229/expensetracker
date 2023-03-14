import 'package:gsheets/gsheets.dart';


class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
   
{
  "type": "service_account",
  "project_id": "expensetracker-380519",
  "private_key_id": "2a5296edebfa1e4623e066818d4b9ba911851ef2",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDpidbfkThzGkE9\nMw2Fe6C/8BLeJx8Gbwvv8hDoMJmS7yEJfD+CHrssCOuVI4leUVX2c66pTM+250QC\nPu+YVFNr1y+EDK50n1luMHBJx/sJogqtdHgBWXMgjEFPQHBQUp1s6e5O32YABhbk\nDfN44q86V67I+9SBAjyw6lugIfBwxClVAr3nHbon8tyKjBFO/Kn6jfyAYE+l3jlB\n55tzQsbCtkC5bYMnY+eUpYGkj7vlIQcjhNMkBc4O44fLlAaQHfoMSNBai4jjxFxj\ntvCy/pN/SZZk68dwVRByo/J41OrZ8/Y5RUpnY1Puv4F9yvXWrIaNZERvo8B+M08R\ni1d6kU7FAgMBAAECggEAIDETG0vkzfT7XjNt3zhclGiZk+GCT3w6LIVKcFSBWYrj\nRm/ylH37oK/KwuBG/LyAeXxBF27nnleVp9ZDZ6o5ZOmgz/aBi8DgGSYjLFXH1HBE\n7DEG+Rn6moIgNIug5RQ7mrpKUmP3/Ekv7u1qDNVOgIp6pOjAcQISb0lMKlrTTm/F\nraCTS9lMDwxlcp2ytVvh4qu98qswWoMoAq9OWzYk21ecjktJwFKp3XD6WhFitiX6\nZvBuImVJ3UJScOJlCp4cCTBW4qLvjRrv/QExMOngEFOH8fjJlEkSSSyu3z9CzUup\n5lJOnL37yLZM2wLk/ScV72R7UMfeRsmTX2Ms2vPs9wKBgQD8hgOxThEUVaiCLJ9Q\nIU4uTkCn5IpMjrRI+nzx26vPzuwd6U7eHaxna+Pkv11U57hdGWBzwHcoT0Q4b0JU\nNYl6HZWEs3G6W5kaauXoPZ10MPQXCxErTvbDxDrtYM8IzyO7NbT0/H1LZ8/8kiid\ng1Go28ZVZFZblvlhXZEel2T9WwKBgQDswOojU7acmhG9Gb6QZdhBdfN46rclkAUg\ngoevHhdEcVY/CkrcKCKfP2XkxLXOhrXKBXPCWsPkSfjgMc/rq/BNADA7BhcALvnI\nInyvNcEQz2aq0j7mqpv9OWiZJbJtKmbWFr9X6iWyy20MruwrhaNyQ/EuEKEd7S+n\n/ij2pNX+XwKBgQDFPwztVtRCdPIt1BsQ5SMDSn54Ziycxi8OfhJQfM0EglWuu4mu\nN7FuCzk0eUG2y1UX63WKlMC+jMP17Pn7euIKr8cVo3DnJxs9Jli1AkPV+VMAGNXt\nZT2dBs8ckizFbb80QSw63GomF02/tI7jEisb4adXFgvaeOAMbKCpK4pn1wKBgHAB\nkIOoDiOmbC/3ZwVveVD22XniKUVXDmXj+wcpCD70E6Z9Ww8u2bpXRwBk49JSPtzV\nmX9ga36sVFbUmhZX4La9GRRDfEw07Sz2y+AkYTNvu5WjI+kC3At/xnF1uSUWQ1KT\nrnCMMMuWm/+9HbQ1ZC8h3484hNDgroQepQiS0T6nAoGARtosfY1rF2qbixRG7dT3\n28Jieb4FHA8Zku6PrkOu+W+5VbshuP5HS46IzmBOouPiaIRVAa/fUlPoGP5NIQXG\n/CPuLrSK1DNtcwumF6ySVNnFltUaPQlN3MP6aRhSDny+vAoof2qx1C+X6kIiCvcT\ni26LS8pV4qsqmAehC0xyBMM=\n-----END PRIVATE KEY-----\n",
  "client_email": "expnseapp@expensetracker-380519.iam.gserviceaccount.com",
  "client_id": "100877615283158311514",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expnseapp%40expensetracker-380519.iam.gserviceaccount.com"
}


  
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1cdzS-HMh0T0Uj5fjl9A54n5wevQdLUfohdaYqF94B8I';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
