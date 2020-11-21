import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:agenda_contatos/helpers/Contact.dart';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  //CRIA A VARIAVEL DO TIPO BANCO DE DADOS
  Database _db;

  //CRIAR OU RECUPERAR O BANCO DE DADOS - REPASSA O BANCO PARA TODAS AS FUNÇÕES
  Future<Database> get db async{
    if(_db != null){
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  //CRIAR O BANCO DE DADOS
  Future<Database> initDb() async{
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    openDatabase(path,version: 1, onCreate: (Database db, int newerVersion)async{
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, "
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  //CRUD - CREATE
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  //CRUD - READ
  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
    columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn], where: "$idColumn = ?", whereArgs: [id]);
    if(maps.length>0){
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //CRUD - UPDATE
  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //CRUD - DELETE
  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //CARREGAR TODOS OS CONTATOS - MODIFIQUEI POR MINHA CONTA E RISCO
  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for(int i; i<listMap.length;i++){
      Map m = listMap.elementAt(i);
      listContact.add(Contact.fromMap(m));
    }
    return await listContact;
  }

  //RETORNA A QUANTIDADE DE CONTATOS
  Future<int> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //FECHA O BANCO DE DADOS
  close()async{
    Database dbContact = await db;
    dbContact.close();
  }

}

