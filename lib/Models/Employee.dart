class Employee{
   String avatar,name,email,joinedOn,phoneNumber;
   Employee({this.name,this.email,this.joinedOn});
   Employee.fromJson(Map<String, dynamic> json){
      this.email=json['email'];
      this.name=json['name'];
      this.phoneNumber=json['phone'];
      this.joinedOn=json['joinedOn'];
      if(json.containsKey("avatar")){
         this.avatar=json['avatar'];
      }
      else{
         avatar=null;
      }
   }
}