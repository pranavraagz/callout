import 'package:callout/styling/custom_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callout/styling/color_palettes.dart';
import 'package:callout/styling/responsive_size.dart';
import 'package:callout/pages/full_post_page.dart';
import 'package:callout/models/post.dart';
import 'package:geocoding/geocoding.dart';

//Figure out calcs for Timestamp and Geopoint

class PostCard extends StatefulWidget {
  final Post post;

  // String userProfileImage = 'assets/images/nav_prof.png';
  // String userName = 'User';
  // String postedAt = '9h'; //Funky maths to calculate
  // String postLocation = 'Location';
  // String postTitle = 'Title';
  // String postDesc =
  //     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis tincidunt felis nisl, eget blandit magna euismod quis. Suspendisse porta mauris sit amet facilisis interdum. Vestibulum sem erat, dictum ac aliquam eget, efficitur nec mauris.';

  PostCard({this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  //Static Variables

  int _stars = 15;
  int _comments = 2;
  int _isStarred = 0;
  _onStarred(int index) {
    setState(() {
      _isStarred = (index + 1) % 2;
      if (_isStarred == 0) {
        _stars++;
      } else {
        _stars--;
      }
    });
  }

  int _currentTimeDiff;

  String _getCurrentTimeDiff() {
    //Check if at least a day has passed
    _currentTimeDiff = Timestamp.now()
        .toDate()
        .difference(widget.post.createdAt.toDate())
        .inHours;
    if (_currentTimeDiff > 24) {
      return (Timestamp.now()
              .toDate()
              .difference(widget.post.createdAt.toDate())
              .inDays
              .toString() +
          'd');
    } else {
      return Timestamp.now()
              .toDate()
              .difference(widget.post.createdAt.toDate())
              .inHours
              .toString() +
          'h';
    }
  }

  String _currentAddress = 'Location';

  Future<String> _getLocationAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          widget.post.location.latitude, widget.post.location.longitude);
      setState(() {
        _currentAddress = placemarks.first.locality;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    _getLocationAddress();

    //Imports the responsive sizes of whatever screen
    SizeConfig().init(context);

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullPostPage(
                      post: widget.post,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: SizeConfig.screenWidth * 0.8,
          height: SizeConfig.screenHeight * 0.3,
          decoration: BoxDecoration(
              color: whiteTint, borderRadius: BorderRadius.circular(11)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.post
                              .userProfileUrl), //Must be Netwrok image for online urls
                          radius: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(widget.post.authorName,
                                      style:
                                          buildBoldRobotoText(18, textColor)),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Color(0xffAAB1BB),
                                    ),
                                  ),
                                  Text(
                                    _getCurrentTimeDiff(),
                                    style: buildRobotoTextStyle(18, neutral),
                                  )
                                ],
                              ),
                              Text(_currentAddress,
                                  style: buildRobotoTextStyle(14, neutral))
                            ],
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: neutral,
                        ),
                        onSelected: (choice) {
                          print("Toggleing");
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                                child: Row(
                              children: [
                                Icon(Icons.flag_outlined),
                                Text('Report'),
                              ],
                            )),
                            PopupMenuItem(
                                child: Row(
                              children: [
                                Icon(Icons.subject),
                                Text('Details'),
                              ],
                            ))
                          ];
                        })
                  ],
                ),
                Text(
                  widget.post.title,
                  style: buildBoldRobotoText(18, Colors.black),
                ),
                Text(widget.post.description,
                    style: buildRobotoTextStyle(11, textColor)),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: _isStarred == 0
                                ? Icon(
                                    Icons.star,
                                    size: 24,
                                  )
                                : Icon(
                                    Icons.star_border,
                                    size: 24,
                                  ),
                            onPressed: () {
                              _onStarred(_isStarred);
                            },
                            color:
                                _isStarred == 0 ? accentYellow : Colors.black,
                          ),
                          Text(_stars.toString(),
                              style: buildRobotoTextStyle(14, textColor)),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(_comments.toString(),
                              style: buildRobotoTextStyle(14, textColor)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 22,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
