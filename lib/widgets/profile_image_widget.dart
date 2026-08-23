import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ProfileImageWidget extends StatefulWidget {


  final String? imageUrl;

  final Function(File) onImageSelected;

  final bool uploading;



  const ProfileImageWidget({

    super.key,

    this.imageUrl,

    required this.onImageSelected,

    this.uploading = false,

  });



  @override
  State<ProfileImageWidget> createState() =>
      _ProfileImageWidgetState();

}




class _ProfileImageWidgetState
    extends State<ProfileImageWidget> {


  File? selectedImage;


  final ImagePicker picker = ImagePicker();


  bool picking = false;



  Future<void> pickImage() async {


    if(picking) return;


    picking = true;



    try{


      final XFile? image =
      await picker.pickImage(

        source: ImageSource.gallery,

        imageQuality: 80,

      );



      if(image != null){


        File file = File(image.path);



        setState(() {

          selectedImage = file;

        });



        widget.onImageSelected(file);


      }



    }catch(e){


      debugPrint(
          "Image picker error: $e"
      );


    }



    picking = false;


  }





  ImageProvider? getImageProvider(){


    if(selectedImage != null){


      return FileImage(selectedImage!);


    }



    if(widget.imageUrl != null &&
        widget.imageUrl!.isNotEmpty){


      return NetworkImage(
          widget.imageUrl!
      );


    }



    return null;


  }






  @override
  Widget build(BuildContext context) {


    return GestureDetector(


      onTap: pickImage,


      child: Stack(


        alignment: Alignment.center,


        children: [



          CircleAvatar(


            radius:55,


            backgroundImage:
            getImageProvider(),



            child:

            getImageProvider() == null

                ?

            const Icon(

              Icons.person,

              size:55,

            )

                :

            null,


          ),





          if(widget.uploading)


            const CircleAvatar(


              radius:55,


              backgroundColor:
              Colors.black45,


              child:


              CircularProgressIndicator(


                color: Colors.white,


              ),



            ),



        ],


      ),


    );


  }


}