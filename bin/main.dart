import 'package:bdProject/bdProject.dart' as bd;
import 'package:sqljocky5/sqljocky.dart';

void main() async {
  // ignore: omit_local_variable_types
  MySqlConnection conn = await bd.createConnection();
  print('create');
  await bd.createTable(conn);
  await bd.inserData(conn);
  await bd.updateData(conn);
  await bd.listData(conn);
  //  await bd.removeData(conn);
  await bd.dropTable(conn);
  //exemplo transação
  await bd.createTables(conn);
  var transaction = await conn.begin();

  try {

    await transaction.execute('insert into pessoa (id, nome, email, idade) values (1, "Castiel Suller", "cas@suller.com", 26)');
    await transaction.execute('insert into cavalo (pessoa_id) values (1)');

    await bd.listData(conn);
    await transaction.commit();

  } catch(e) {

    print(e);
    await transaction.rollback();
  }

  await bd.dropTable(conn);
  print('close');
  await conn.close();
}