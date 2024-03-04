import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/chatuser.dart';
import '../Widgets/navigation.dart';
import '../main.dart';
import '../message.dart';

class ProfileScreen extends StatefulWidget {
  //final ChatUser user;

  const ProfileScreen({super.key}); //required this.user

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ChatUser?> _user;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    APIs.getSelf();
    _user = APIs.getMe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Чаты"),
      ),
      endDrawer: const NavigationDrawerWidget(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: FutureBuilder<ChatUser?>(
            future: _user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                if (snapshot.hasData && snapshot.data != null) {
                  final ChatUser user = snapshot.data!;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                    child: Column(
                      children: [
                        SizedBox(width: mq.width, height: mq.height * .03),
                        Stack(
                          children: [
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.fill,
                                  imageUrl: user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(
                                    CupertinoIcons.person,
                                    size: 50,
                                  )),
                                )),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: MaterialButton(
                                  elevation: 1,
                                  onPressed: () {
                                    _showBottom();
                                  },
                                  shape: CircleBorder(),
                                  color: Colors.white,
                                  child: Icon(Icons.edit, color: Colors.blue)),
                            )
                          ],
                        ),
                        SizedBox(height: mq.height * .03),
                        Text(user.email,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 16)),
                        SizedBox(height: mq.height * .05),
                        TextFormField(
                            initialValue: user.name,
                            onSaved: (val) => APIs.me.name = val ?? '',
                            validator: (val) => val != null && val.isNotEmpty
                                ? null
                                : 'Неверные поля',
                            decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.person, color: Colors.blue),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                label: Text("Имя"))),
                        SizedBox(height: mq.height * .02),
                        TextFormField(
                            initialValue: user.about,
                            onSaved: (val) => APIs.me.about = val ?? '',
                            validator: (val) => val != null && val.isNotEmpty
                                ? null
                                : 'Неверное имя',
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.info_outline,
                                    color: Colors.blue),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                label: Text("О себе"))),
                        SizedBox(height: mq.height * .03),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                minimumSize:
                                    Size(mq.width * .4, mq.height * .06)),
                            onPressed: () async {
                              _formKey.currentState!.save();

                              if (_formKey.currentState!.validate()) {
                                final nameExists =
                                    await APIs.userWithNameExists(APIs.me.name);
                                if (nameExists) {
                                  showToast(
                                      message:
                                          "Пользователь c таким именем уже существует.");
                                  return;
                                }

                                APIs.updateUserInfo();
                                showToast(
                                    message: "Пользователь успешно обновлен!");
                              }
                            },
                            icon: const Icon(
                              Icons.edit,
                              size: 30,
                            ),
                            label: const Text("Обновить",
                                style: TextStyle(fontSize: 16)))
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('No data'));
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void _showBottom() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              Text('Изменить фото профиля',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              SizedBox(height: mq.height *.02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height *.15)
                        ),
                          onPressed: () async{
                          /*final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if(image != null){
                            print("Image path: ${image.path} ---- and type ${image.mimeType}");
                          }*/
                          },
                          child: Image.asset('images/gallery.png')),
                      SizedBox(height: mq.height * .005),
                      Text("Выбрать из галереи",style: TextStyle( fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const CircleBorder(),
                              fixedSize: Size(mq.width * .3, mq.height *.15)
                          ),
                          onPressed: (){},
                          child: Image.asset('images/camera.png')),
                      SizedBox(height: mq.height * .005),
                      Text("Сделать фото",style: TextStyle( fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              )
            ],
          );
        });
  }
}
