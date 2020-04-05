import 'package:sqljocky5/sqljocky.dart';
import 'dart:async';

Future<MySqlConnection> createConnection() async {
  var s = ConnectionSettings(
    user: "root",
    host: "localhost",
    password: '123456',
    port: 3306,
    db: "dart",
  );
  var conn = MySqlConnection.connect(s);
  return conn;
}

Future<void> createTable(MySqlConnection conn) async{
  print('Criando Tabela...');
  await conn.execute('CREATE TABLE IF NOT EXISTS pessoa (id INTEGER NOT NULL auto_increment, nome VARCHAR(255), idade INTEGER, email VARCHAR(255), PRIMARY KEY(id)  )');
  print('Tabela criada com sucess!!!');
}

Future<void> inserData(MySqlConnection conn) async {
  print("Inserindo dados ...");

  var data = [
    ['Carlos', 'carlos@carl.com', 26],
    ['Villa', 'villa@villa.com', 23],
    ['Gaby', 'gaby@gaby.com', 22],
  ];
  await conn.preparedWithAll("INSERT INTO pessoa (nome, email, idade) VALUES (?, ?, ?)", data);
}

Future<void> updateData(MySqlConnection conn) async {
  print('\n\nAtualizando dados...');
  await conn.prepared('UPDATE pessoa SET nome = ? where id = ?', ['Castiel', 13]);
}

Future<void> listData(MySqlConnection conn) async {
  print('Listando dados');
  StreamedResults results = await conn.execute('SELECT * FROM pessoa');
  results.forEach((Row row) => print('ID: ${row[0]}, Nome: ${row[1]}, Idade: ${row[2]}, Email: ${row[3]},'));
}

Future<void> removeData(MySqlConnection conn) async {
  print('\nRemovendo dados...');
  await conn.execute('DELETE FROM pessoa');
}

Future<void> dropTable(MySqlConnection conn) async {
  print('\nExcluindo Tabela...');
  await conn.execute('DROP TABLE IF EXISTS pessoa');
}
