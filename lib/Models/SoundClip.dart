class SoundClip{
   String soundId,clipUri,title,description,datetime,uid;
   bool playing,loading;

   SoundClip({this.title,this.description,this.clipUri});
   SoundClip.fromJson(Map<String, dynamic> json) {
      soundId = json['sid'];
      title = json['title'];
      uid = json['email'];
      description = json['description'];
      clipUri = json['downloadUrl'];
      datetime = json['datetime'];
      playing=false;
      loading=false;
   }

}