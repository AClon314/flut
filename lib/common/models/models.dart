extension NullSaveParser on String {
  DateTime? tryToDatetime() {
    return DateTime.tryParse(this);
  }
}
extension NullSaveParser2 on String? {
  DateTime? tryToDatetime() {
    if (this==null) {
      return null;
    } else {
      return DateTime.tryParse(this!);
    }
  }
}

String globalUserId='test';
// 4808660988691742721 cat
// 4808660988490416129 banana
class Models {
  
}

class DBresponse extends Models {
  num? rowcount;
  final bool soft_closed;
  DBresponse(this.soft_closed);
  DBresponse.fromJson(Map<String, dynamic> json)
      : rowcount = json['rowcount'],
        soft_closed = json['_soft_closed'];
}

class Userinfo extends Models {
  final String userinfo_id;
  final String username;
  final String? pwd;
  final String? pwd_sault;
  final String? nick;
  final String? phone;
  final String? email;
  final String? intro;
  final String? avatar;
  final String? sex;
  final DateTime? birth;
  final String? pos;
  final num? days_online;
  final DateTime? last_online;
  final num? posts_watched;
  final num? posts_count_ord;
  final num? posts_count_works;
  final String? status;
  final num? following;
  final num? friends;
  final num? outcome_total;
  final num? outcome_monthly;
  final num? supporting;

  Userinfo({
      required this.userinfo_id,
      required this.username,
      this.pwd,
      this.pwd_sault,
      this.nick,
      this.phone,
      this.email,
      this.intro,
      this.avatar,
      this.sex,
      this.birth,
      this.pos,
      this.days_online,
      this.last_online,
      this.posts_watched,
      this.posts_count_ord,
      this.posts_count_works,
      this.status,
      this.following,
      this.friends,
      this.outcome_total,
      this.outcome_monthly,
      this.supporting});
  
  static DateTime? tryToDatetime(String? str) {
    if (str==null) {
      return null;
    } else {
      return DateTime.tryParse(str);
    }
  }

  Userinfo.fromJson(Map<String, dynamic> json)
      : userinfo_id = json['userinfo_id'],
        username = json['username'],
        pwd = json['pwd'],
        pwd_sault = json['pwd_sault'],
        nick = json['nick'],
        phone = json['phone'],
        email = json['email'],
        intro = json['intro'],
        avatar = json['avatar'],
        sex = json['sex'],
        birth = tryToDatetime(json['birth']),
        pos = json['pos'],
        days_online = json['days_online'],
        last_online = tryToDatetime(json['last_online']),
        posts_watched = json['posts_watched'].toInt(),
        posts_count_ord = json['posts_count_ord'].toInt(),
        posts_count_works = json['posts_count_works'].toInt(),
        status = json['status'],
        following = json['following'].toInt(),
        friends = json['friends'].toInt(),
        outcome_total = json['outcome_total'],
        outcome_monthly = json['outcome_monthly'],
        supporting = json['supporting'].toInt();

  Map<String, dynamic> toJson() => {
        'userinfo_id': userinfo_id,
        'username': username,
        'pwd': pwd,
        'pwd_sault': pwd_sault,
        'nick': nick,
        'phone': phone,
        'email': email,
        'intro': intro,
        'avatar': avatar,
        'sex': sex,
        'birth': birth,
        'pos': pos,
        'days_online': days_online,
        'last_online': last_online,
        'posts_watched': posts_watched,
        'posts_count_ord': posts_count_ord,
        'posts_count_works': posts_count_works,
        'status': status,
        'following': following,
        'friends': friends,
        'outcome_total': outcome_total,
        'outcome_monthly': outcome_monthly,
        'supporting': supporting,
      };
}

class Post extends Models {
  final String post_id;
  String? classes;
  final DateTime time_init;
  DateTime? time_edit;
  DateTime? time_update;
  String owner_url;
  String? path;
  String? title;
  String? url;
  String? protocol;
  final String status;
  String? remain_act;
  DateTime? remain_time;
  num? remain_buy=0;
  num? price=0;
  num? credit_level=0;
  num? income_total=0;
  num? income_monthly=0;
  num? supported=0;
  num? expose=0;
  num? click=0;
  num? time_stay=0;
  num? ing=0;
  num? favor=0;
  num? replys=0;
  num? sponsors=0;
  num? reported=0;
  num? likes=0;
  num? dislike=0;
  num? repost=0;
  // late final String? nick;
  // late final String? username;
  Post({required this.post_id,required this.time_init,required this.owner_url,required this.status});

  Post.fromJson(Map<String, dynamic> json)
      : post_id = json['post_id'],
        classes = json['classes'],
        time_init = DateTime.parse(json['time_init']),
        time_edit = json['time_edit']?.tryToDatetime(),
        time_update = json['time_edit']?.tryToDatetime(),
        owner_url = json['owner_url'],
        path = json['path'],
        title = json['title'],
        url = json['url'],
        protocol = json['protocol'],
        status = json['status'] ?? 'UNKNOWN',
        remain_act = json['remain_act'],
        remain_time = json['remain_time'],
        remain_buy = json['remain_buy'],
        price = json['price'],
        credit_level = json['credit_level'],
        income_total = json['income_total'],
        income_monthly = json['income_monthly'],
        supported = json['supported'].toInt(),
        expose = json['expose'],
        click = json['click'].toInt(),
        time_stay = json['time_stay'],
        ing = json['ing'].toInt(),
        favor = json['favor'].toInt(),
        replys = json['replys'].toInt(),
        sponsors = json['sponsors'].toInt(),
        reported = json['reported'].toInt(),
        likes = json['likes'].toInt(),
        dislike = json['dislike'].toInt(),
        repost = json['repost'].toInt();
  Map<String, dynamic> toJson() => {
        'post_id': post_id,
        'classes': classes,
        'time_init': time_init,
        'time_edit': time_edit,
        'time_update': time_update,
        'owner_url': owner_url,
        'path': path,
        'title': title,
        'url': url,
        'protocol': protocol,
        'status': status,
        'remain_act': remain_act,
        'remain_time': remain_time,
        'remain_buy': remain_buy,
        'price': price,
        'credit_level': credit_level,
        'income_total': income_total,
        'income_monthly': income_monthly,
        'supported': supported,
        'expose': expose,
        'click': click,
        'time_stay': time_stay,
        'ing': ing,
        'favor': favor,
        'replys': replys,
        'sponsors': sponsors,
        'reported': reported,
        'likes': likes,
        'dislike': dislike,
        'repost': repost,
      };
}

class Relation extends Models {
  final DateTime rtime;
  final String userinfo_id;
  final String post_id;
  final String status;
  final num? xlock;
  Relation(this.rtime, this.userinfo_id, this.post_id, this.status, this.xlock);

  Relation.fromJson(Map<String, dynamic> json)
      : rtime = json['rtime'],
        userinfo_id = json['userinfo_id'],
        post_id = json['post_id'],
        status = json['status'],
        xlock = json['xlock'];

  Map<String, dynamic> toJson() => {
        'rtime': rtime,
        'userinfo_id': userinfo_id,
        'post_id': post_id,
        'status': status,
        'xlock': xlock,
      };
}

class Interact extends Models {
  final DateTime itime;
  final String userinfo_id;
  final String post_id;
  final String act;
  Interact(this.itime, this.userinfo_id, this.post_id, this.act);

  Interact.fromJson(Map<String, dynamic> json)
      : itime = json['itime'],
        userinfo_id = json['userinfo_id'],
        post_id = json['post_id'],
        act = json['act'];

  Map<String, dynamic> toJson() => {
        'itime': itime,
        'userinfo_id': userinfo_id,
        'post_id': post_id,
        'act': act,
      };
}

class Cart extends Models {
  final String cart_id;
  final String status;
  final String userinfo_id;
  final String post_id;
  final String? coupon_id;
  final String? coupon_price;
  final num price_total;
  final num? price_shouldpay;
  final String pay_method;
  final String? invoice_id;
  Cart(
      this.cart_id,
      this.status,
      this.userinfo_id,
      this.post_id,
      this.coupon_id,
      this.coupon_price,
      this.price_total,
      this.price_shouldpay,
      this.pay_method,
      this.invoice_id);
  Cart.fromJson(Map<String, dynamic> json)
      : cart_id = json['cart_id'],
        status = json['status'],
        userinfo_id = json['userinfo_id'],
        post_id = json['post_id'],
        coupon_id = json['coupon_id'],
        coupon_price = json['coupon_price'],
        price_total = json['price_total'],
        price_shouldpay = json['price_shouldpay'],
        pay_method = json['pay_method'],
        invoice_id = json['invoice_id'];

  Map<String, dynamic> toJson() => {
        'cart_id': cart_id,
        'status': status,
        'userinfo_id': userinfo_id,
        'post_id': post_id,
        'coupon_id': coupon_id,
        'coupon_price': coupon_price,
        'price_total': price_total,
        'price_shouldpay': price_shouldpay,
        'pay_method': pay_method,
        'invoice_id': invoice_id,
      };
}

class Pay extends Models {
  final String pay_id;
  final num money;
  final DateTime time_init;
  final DateTime? time_edit;
  final String? addr;
  final num quantity;
  final String? remark;
  final String? express_id;
  final String userinfo_id;
  final String post_id;
  final String? prev_url;
  Pay(
      this.pay_id,
      this.money,
      this.time_init,
      this.time_edit,
      this.addr,
      this.quantity,
      this.remark,
      this.express_id,
      this.userinfo_id,
      this.post_id,
      this.prev_url);
  Pay.fromJson(Map<String, dynamic> json)
      : pay_id = json['pay_id'],
        money = json['money'],
        time_init = json['time_init'],
        time_edit = json['time_edit'],
        addr = json['addr'],
        quantity = json['quantity'],
        remark = json['remark'],
        express_id = json['express_id'],
        userinfo_id = json['userinfo_id'],
        post_id = json['post_id'],
        prev_url = json['prev_url'];

  Map<String, dynamic> toJson() => {
        'pay_id': pay_id,
        'money': money,
        'time_init': time_init,
        'time_edit': time_edit,
        'addr': addr,
        'quantity': quantity,
        'remark': remark,
        'express_id': express_id,
        'userinfo_id': userinfo_id,
        'post_id': post_id,
        'prev_url': prev_url,
      };
}
