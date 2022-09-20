import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

const String listSymbolsDoc = r'''
  query listSymbols {
    listSymbols {
      success
      errors
      symbols {
        name
      }
    }
  }
''';

const String getWatchListDoc = r'''
query getWatchList {
  getWatchList {
    success
    errors
    items {
      symbol { name }
      time
      open
      high
      low
      close
      wap
      volume
    }
  }
}
''';

class Symbol {
  String name;
  Symbol(this.name);
}

class WatchListItem {
  Symbol symbol;
  DateTime time;
  double open;
  double high;
  double low;
  double close;
  double wap;
  int volume;

  WatchListItem(this.symbol, this.time, this.open, this.high, this.low,
      this.close, this.wap, this.volume);
}

class SymbolList extends StatelessWidget {
  const SymbolList({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    print("Building symbols list!");
    return Query(
      options: QueryOptions(
        document: gql(listSymbolsDoc),
        pollInterval: const Duration(seconds: 10),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (QueryResult result, {refetch, fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return const Text('Loading');
        }

        // it can be either Map or List
        List symbols = result.data!['listSymbols']['symbols'];

        return ListView.builder(
            itemCount: symbols.length,
            itemBuilder: (context, index) {
              return Text(symbols[index]['name']);
            });
      },
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({Key? key}) : super(key: key);

  static final subscriptionDocument = gql(
    r'''
      subscription counter {
        counter {
          success
          errors
          count
        }
      }
    ''',
  );

  @override
  Widget build(context) {
    print("Building counter!");
    return Subscription(
      options: SubscriptionOptions(document: subscriptionDocument),
      builder: (result) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }
        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final int count = result.data!['counter']['count'];
        return Text("Counter: $count");
      },
    );
  }
}
