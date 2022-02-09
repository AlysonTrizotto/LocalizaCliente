import 'package:flutter/material.dart';

class lista_categoria extends StatelessWidget {
    static const IconData local_pharmacy = IconData(0xe39e, fontFamily: 'MaterialIcons');
  // Classe que apresenta os dados
  @override
  Widget build(BuildContext context) {


    // Construtor dos Icones
    return Scaffold(
      body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child:  SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(Icons.people),
              title: Text('Cliente'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.hotel_rounded),
              title: Text('Hotel'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_gas_station_outlined),
              title: Text('Posto de combustível'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.food_bank_outlined),
              title: Text('Restaurantes'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.shopping_cart_outlined),
              title: Text('Mercado'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_hospital_rounded),
              title: Text('Hospital'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(local_pharmacy),
              title: Text('Farmácia'),
            ),
          ),
        ],
       ),
     ),
     ),
   );
  }
}