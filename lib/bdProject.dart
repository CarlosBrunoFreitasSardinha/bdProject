import 'package:sqljocky5/connection/impl.dart';
import 'package:sqljocky5/sqljocky.dart';
import 'dart:async';
import 'dart:core';

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

Future<void> createTable(MySqlConnection conn) async {
  // print('Criando Tabela Pessoa...');
  String sql = """CREATE TABLE IF NOT EXISTS 
                    pessoa(
                          id INTEGER NOT NULL auto_increment, 
                          nome VARCHAR(255), 
                          idade INTEGER, 
                          email VARCHAR(255), 
                          PRIMARY KEY(id)
                          )""";
  await conn.execute(sql);
  // print('Tabela criada com sucess!!!');
}

Future<void> inserData(MySqlConnection conn) async {
  print("Inserindo dados ...");

  var data = [
    ['Carlos', 'carlos@carl.com', 26],
    ['Villa', 'villa@villa.com', 23],
    ['Gaby', 'gaby@gaby.com', 22],
  ];
  await conn.preparedWithAll(
      "INSERT INTO pessoa (nome, email, idade) VALUES (?, ?, ?)", data);
}

Future<void> updateData(MySqlConnection conn) async {
  print('\n\nAtualizando dados...');
  await conn
      .prepared('UPDATE pessoa SET nome = ? where id = ?', ['Castiel', 1]);
}

Future<void> listData(MySqlConnection conn, String table) async {
  print('\n.:$table :.');
  StreamedResults results = await conn.execute('SELECT * FROM $table');
  results.forEach((Row row) => print('ID: ${row[0]}, descricao: ${row[1]}, preco: ${row[2]}, dat: ${row[3]};'));
}

Future<void> listHistorico(MySqlConnection conn, String table) async {
  print('\n.:$table :.');
  StreamedResults results = await conn.execute("SELECT id, produto_id, GETFULLNAME(descricao, 'Fullname'), preco, dat, acao FROM $table");
  results.forEach((Row row) => print('ID: ${row[0]}, produto_id: ${row[1]}, descricao: ${row[2]}, preco: ${row[3]}, dat: ${row[4]}, acao: ${row[5]};'));
}

Future<void> removeData(MySqlConnection conn, String tabela) async {
  print('\nRemovendo dados...');
  await conn.execute('DELETE FROM $tabela');
}

Future<void> dropTables(MySqlConnection conn) async {
  print('\nExcluindo Tabelas...');
  await conn.execute('DROP TABLE IF EXISTS historicoProdutos, compra, produto, pessoa');
}

Future<void> createTables(MySqlConnection conn) async {
  print("Criando tabelas ...");
  await conn.execute(
      """
      CREATE TABLE IF NOT EXISTS 
      pessoa (
              id INTEGER NOT NULL auto_increment, 
              nome VARCHAR(255), 
              idade INTEGER, 
              email VARCHAR(255), 
              PRIMARY KEY(id))
      """);
  await conn.execute(
      """CREATE TABLE IF NOT EXISTS 
            produto(
              id INTEGER NOT NULL auto_increment, 
              descricao VARCHAR(255), 
              preco INTEGER, 
              dat TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
              PRIMARY KEY(id)
              )""");
  await conn.execute(
      """CREATE TABLE IF NOT EXISTS 
            compra (
              id INTEGER NOT NULL auto_increment, 
              pessoa_id INTEGER NOT NULL, 
              produto_id INTEGER NOT NULL, 
              quant INTEGER, 
              PRIMARY KEY (id), 
              FOREIGN KEY (pessoa_id) REFERENCES pessoa(id), 
              FOREIGN KEY (produto_id) REFERENCES produto(id)
              )""");
  await conn.execute(
      """CREATE TABLE IF NOT EXISTS 
              historicoProdutos (
                id INTEGER NOT NULL auto_increment, 
                produto_id INTEGER NOT NULL, 
                descricao VARCHAR(255), 
                preco INTEGER, 
                dat DATETIME, 
                acao VARCHAR(50), 
                PRIMARY KEY (id), 
                FOREIGN KEY (produto_id) REFERENCES produto(id)
                )""");
}

Future<void> insertData(MySqlConnection conn) async {
  print("Inserindo dados ...");

  var data_pessoa = [
    ['Carlos', 'carlos@carl.com', 26],
    ['Villa', 'villa@villa.com', 23],
    ['Gaby', 'gaby@gaby.com', 22],
  ];
  await conn.preparedWithAll(
      "INSERT INTO pessoa (nome, email, idade) VALUES (?, ?, ?)", data_pessoa);

  await new Future.delayed(const Duration(seconds: 1));
  var data_produtos = [
    ['Maçã', 20],
    ['Pera', 15],
    ['kiwi', 10],
  ];

  await conn.preparedWithAll(
      "INSERT INTO produto (descricao, preco) VALUES (?, ?)",
      data_produtos);

  await new Future.delayed(const Duration(seconds: 1));
  var data_compras = [
    [1, 1, 6],
    [1, 2, 2],
    [2, 3, 3],
  ];
  await conn.preparedWithAll(
      "INSERT INTO compra (pessoa_id, produto_id, quant) VALUES (?, ?, ?)",
      data_compras);
}

Future<void> createBD2(MySqlConnection conn) async {
  // ignore: omit_local_variable_types
  String procedure = "CREATE PROCEDURE alterDp(IN i INT, IN d varchar(255),IN p INT) BEGIN UPDATE produto SET descricao = d where id = i;UPDATE produto SET preco = p where id = i; END";

  // ignore: omit_local_variable_types 
  String trigger =
      """CREATE TRIGGER auto_update 
            BEFORE UPDATE ON produto 
            FOR EACH ROW 
              INSERT historicoProdutos 
              SET acao = 'update', descricao = OLD.descricao, preco = OLD.preco, produto_id = OLD.id, dat = NOW();
      """;

  // ignore: omit_local_variable_types
  String view = 'CREATE VIEW todasAsPessoas AS SELECT * FROM produto;';

  // ignore: omit_local_variable_types
  String functx = 'CREATE FUNCTION retornaAno(myvariable DATE) RETURNS INT BEGIN RETURN YEAR(myvariable); END;';

  // ignore: omit_local_variable_types
  String functy =
            """CREATE FUNCTION GETFULLNAME(fname CHAR(250),lname CHAR(250))
                RETURNS CHAR(250) 
                BEGIN
                  DECLARE fullname CHAR(250);
                  SET fullname=CONCAT(fname,' ',lname); 
                  RETURN fullname;
                END""";

  print('iniciando atividade de fato');
  await conn.execute(procedure);
  print("Create prcedure");
  await conn.execute(trigger);
  print("Create trigger");
  await conn.execute(view);
  print("Create view");
  await conn.execute(functx);
  print("Create funct");
  await conn.execute(functy);
  print("Create funct");
}

Future<void> useProcedure(MySqlConnection conn) async {
  print("executando procedure...");
  var transaction = await conn.begin();

  try {

    await transaction.execute('CALL alterDp(2,"tomate",22);');
    await transaction.commit();

  } catch(e) {

    print(e);
    await transaction.rollback();
  }
}

Future<void> dropBD2(MySqlConnection conn) async {
  print('Excluindo recursos passados...\n');
  await conn.execute('DROP PROCEDURE IF EXISTS alterDp;');
  await conn.execute('DROP TRIGGER IF EXISTS auto_update;');
  await conn.execute('DROP VIEW IF EXISTS todasAsPessoas;');
  await conn.execute('DROP FUNCTION IF EXISTS GETFULLNAME;');
  await conn.execute('DROP FUNCTION IF EXISTS retornaAno;');
}
