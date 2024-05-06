import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../data/telegram/telegram_app.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class ChannelItem extends StatelessWidget {
  final Channel channel;

  const ChannelItem({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: ListTile(
        onTap: () async {},
        leading: SizedBox(
          height: 54,
          width: 54,
          child: SvgPicture.asset(
            'assets/svg/coin.svg',
          ),
        ),
        title: Text(channel.name,
            style: TextStyles.activeTitleItem,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(channel.description,
            style: TextStyles.subtitleComDes,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        trailing: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Color(0xFFF7D357), Color(0xFFE09528)],
            ),
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              if (channel.type == 0) {
                telegram.openTelegramLink(channel.link);
              } else {
                telegram.openWebLink(channel.link);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsTheme.background,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Join', style: TextStyles.textInComButton),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: ColorsTheme.startGradientColor,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Channel {
  final String name;
  final String description;
  final int type;
  final String link;

  Channel(
      {required this.name,
      required this.description,
      required this.type,
      required this.link});
}
