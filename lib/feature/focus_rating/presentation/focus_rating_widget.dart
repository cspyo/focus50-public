import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus42/feature/focus_rating/view_model/provider.dart';

class RatingWidget extends ConsumerStatefulWidget {
  final double starSize = 40.0;
  final double initialRating = 0;
  final starColor = Colors.amber;

  const RatingWidget();

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends ConsumerState<RatingWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      child: Container(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Text(
                            "포공 세션이 종료되었습니다",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Text(
                          "집중도를 평가해주세요",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: RatingBar.builder(
                        initialRating: widget.initialRating,
                        glowColor: widget.starColor,
                        minRating: 1,
                        itemSize: widget.starSize,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        onRatingUpdate: (rating) {
                          ref.read(ratingCountStateProvider.notifier).state =
                              rating;
                        },
                        itemBuilder: (context, _) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(
                            Icons.star,
                            color: widget.starColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Divider(
                    thickness: 0.3,
                    color: Colors.black38,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
