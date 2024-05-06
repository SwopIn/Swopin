import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/analytics_service.dart';
import '../../common/widgets/back_button.dart';
import '../widgets/community_widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Channel> channels = [
    Channel(
        name: 'Telegram',
        description: 'Swopin announcement',
        type: 0,
        link: 'https://t.me/swopin'),
    Channel(
        name: 'Twitter',
        description: 'Swopin news',
        type: 1,
        link: 'https://x.com/swopin_nft'),
  ];

  @override
  void initState() {
    super.initState();
    analytics.logCommunityScreenOpen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const CustomTopBarForCommunity(title: 'Community'),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorsTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: channels.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      child: Divider(height: 1, color: ColorsTheme.primary),
                    );
                  },
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    return ChannelItem(
                      channel: channel,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class CustomTopBarForCommunity extends StatelessWidget {
  final String title;

  const CustomTopBarForCommunity({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CustomBackButton(),
        Text(title, style: TextStyles.topBarTitle),
        const SizedBox(width: 64),
      ],
    );
  }
}
