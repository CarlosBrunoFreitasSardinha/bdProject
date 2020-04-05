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

  print('close');
  await conn.close();
}