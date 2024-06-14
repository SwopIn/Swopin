import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swopin/data/telegram/telegram_app.dart';
import 'package:swopin/data/user/user_repository.dart';

class Referral {
  final int id;
  final int refCount;

  Referral(this.id, this.refCount);

  String get name => _generateAnimalDescription(id);

  Map<String, dynamic> toMap() {
    return {
      'tg_id': id,
      'ref_count': refCount,
    };
  }

  static Referral fromMap(Map<String, dynamic> map) {
    return Referral(
      map['tg_id'],
      map['ref_count'],
    );
  }

  // Метод toString
  @override
  String toString() {
    return 'Referral{tg_id: $id, refCount: $refCount}';
  }

  String _generateAnimalDescription(int userId) {
    List<String> adjectives = [
      'Unique',
      'Rare',
      'Valuable',
      'Exclusive',
      'Innovative',
      'Revolutionary',
      'Digital',
      'Virtual',
      'Boundless',
      'Decentralized',
      'Secure',
      'Private',
      'Anonymous',
      'Transparent',
      'Open',
      'Global',
      'Reliable',
      'Stable',
      'Dynamic',
      'Promising',
      'Powerful',
      'Efficient',
      'Modern',
      'Fast',
      'Flexible',
      'Mobile',
      'Optimized',
      'Intelligent',
      'Autonomous',
      'Complex',
      'Simple',
      'Smart',
      'International',
      'Local',
      'Personalized',
      'Functional',
      'Compact',
      'Mass',
      'Individual',
      'Open'
    ];

    List<String> nouns = [
      'Bitcoin',
      'Ethereum',
      'Blockchain',
      'Token',
      'Cryptocurrency',
      'Mining',
      'Satoshi',
      'DeFi',
      'SmartContract',
      'NFT',
      'Artifact',
      'Cryptography',
      'Hash',
      'PublicKey',
      'PrivateKey',
      'Address',
      'Wallet',
      'Exchange',
      'ICO',
      'DAO',
      'Gas',
      'Staking',
      'Farming',
      'Liquidity',
      'Decentralization',
      'Sharding',
      'Sidechain',
      'Metaverse',
      'CryptoArt',
      'Kitty',
      'Punk',
      'Enthusiast',
      'Investor',
      'Analyst',
      'Trader',
      'Economy',
      'Bot',
      'Farm',
      'Asset',
      'Artifact'
    ];

    int hash = userId.hashCode;
    int adjIndex = hash % adjectives.length;
    int nounIndex = (hash ~/ adjectives.length) % nouns.length;
    return '${adjectives[adjIndex]} ${nouns[nounIndex]}';
  }
}

abstract class ReferralsRepository {
  /// Fetches the list of referrals.
  ///
  /// Returns a [BehaviorSubject] that emits a list of top referrals.
  BehaviorSubject<List<Referral>> fetchTopPlayers({required int count});
}

class ReferralsRepositoryImpl implements ReferralsRepository {
  final _supaBase = Supabase.instance.client;

  final UserRepository userRepository;

  ReferralsRepositoryImpl({required this.userRepository});

  @override
  BehaviorSubject<List<Referral>> fetchTopPlayers({required int count}) {
    final BehaviorSubject<List<Referral>> result =
        BehaviorSubject<List<Referral>>();
    _supaBase
        .rpc('fetch_top_refs', params: {'_count': count})
        .select()
        .then((value) {
          if (value.isEmpty) {
            result.addError('Users not found');
            return;
          }
          final top = value.map((e) => Referral.fromMap(e)).toList();
          if (top.any((element) => element.id == telegram.userId)) {

          }else{
            final myRefCount = userRepository.user.value.refCount;
            top.add(Referral(telegram.userId!, myRefCount));
          }

          result.add(top);
        })
        .catchError((error) {
          result.addError(error);
        });
    return result;
  }
}
