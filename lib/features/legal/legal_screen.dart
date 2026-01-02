import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LegalScreen extends ConsumerWidget {
  final String type; // 'privacy', 'terms', or 'about'

  const LegalScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final fontSize = settings.fontSize;
    final isPrivacy = type == 'privacy';
    final isTerms = type == 'terms';
    final isAbout = type == 'about';

    // Language selection
    final showChinese = settings.language == 'zh';

    String title;
    String content;
    String contactTitle;
    String contactContent;

    if (isPrivacy) {
      title = showChinese ? '隐私政策' : 'PRIVACY POLICY';
      content = showChinese ? _privacyContentChinese : _privacyContent;
      contactTitle = showChinese ? '联系我们' : 'CONTACT US';
      contactContent = showChinese
          ? '有关隐私政策的疑问：\n\n'
              '邮箱：privacy@casezero.com\n'
              '网址：www.casezero.com\n'
              '地址：123 调查街，侦探市'
          : 'For questions about these policies:\n\n'
              'Email: privacy@casezero.com\n'
              'Website: www.casezero.com\n'
              'Address: 123 Investigation St, Detective City';
    } else if (isTerms) {
      title = showChinese ? '条款与条件' : 'TERMS & CONDITIONS';
      content = showChinese ? _termsContentChinese : _termsContent;
      contactTitle = showChinese ? '联系我们' : 'CONTACT US';
      contactContent = showChinese
          ? '有关条款的疑问：\n\n'
              '邮箱：legal@casezero.com\n'
              '网址：www.casezero.com\n'
              '地址：123 调查街，侦探市'
          : 'For questions about these terms:\n\n'
              'Email: legal@casezero.com\n'
              'Website: www.casezero.com\n'
              'Address: 123 Investigation St, Detective City';
    } else {
      title = showChinese ? '关于应用' : 'ABOUT THE APP';
      content = showChinese ? _aboutContentChinese : _aboutContent;
      contactTitle = showChinese ? '联系我们' : 'CONTACT US';
      contactContent = showChinese
          ? '应用问题反馈：\n\n'
              '邮箱：support@casezero.com\n'
              '网址：www.casezero.com\n'
              '地址：123 调查街，侦探市'
          : 'For app support:\n\n'
              'Email: support@casezero.com\n'
              'Website: www.casezero.com\n'
              'Address: 123 Investigation St, Detective City';
    }

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header with language toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.neonRed.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.neonRed,
                      size: 28.0 * fontSize,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.0 * fontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neonRed,
                        fontFamily: 'Courier New',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  // Language Toggle Button
                  IconButton(
                    onPressed: () {
                      final notifier = ref.read(settingsProvider.notifier);
                      final newLanguage = showChinese ? 'en' : 'zh';
                      notifier.setLanguage(newLanguage);
                    },
                    icon: Icon(
                      showChinese ? Icons.language : Icons.translate,
                      color: AppColors.neonBlue,
                      size: 24.0 * fontSize,
                    ),
                    tooltip: showChinese ? 'Switch to English' : '切换到中文',
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Last Updated with language indicator
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.neonBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.neonBlue),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.update,
                              color: AppColors.neonBlue, size: 20 * fontSize),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              showChinese
                                  ? '最后更新：2024年12月 | 语言：中文'
                                  : 'Last Updated: December 2024 | Language: English',
                              style: TextStyle(
                                color: AppColors.neonBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0 * fontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Content
                    Text(
                      content,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.0 * fontSize,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Contact Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.neonRed.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contactTitle,
                            style: TextStyle(
                              color: AppColors.neonRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0 * fontSize,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            contactContent,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.0 * fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // English Privacy Policy
  final String _privacyContent = '''
1. INFORMATION WE COLLECT

Case Zero: Detective collects the following information:
- Game progress and save data
- Device information for compatibility
- Anonymous usage statistics
- In-app purchase records

2. HOW WE USE YOUR INFORMATION

We use collected information to:
- Save your game progress
- Improve game performance
- Provide customer support
- Ensure fair gameplay

3. DATA SECURITY

We implement security measures to protect your data:
- Local storage encryption
- Secure server connections
- Regular security audits

4. THIRD-PARTY SERVICES

We use trusted third-party services for:
- Analytics (Google Analytics)
- Cloud saves (Firebase)
- Payment processing (Google Play Store)

5. CHILDREN'S PRIVACY

Case Zero is not intended for children under 13. We do not knowingly collect personal information from children under 13.

6. YOUR RIGHTS

You have the right to:
- Access your data
- Delete your data
- Opt-out of analytics
- Contact us about privacy concerns

7. DATA RETENTION

We retain your game data as long as your account is active. You can request deletion at any time.

8. CHANGES TO POLICY

We may update this policy. We will notify you of significant changes through the app or email.

9. CONSENT

By using Case Zero, you consent to this privacy policy.
''';

  // Chinese Privacy Policy (简体中文)
  final String _privacyContentChinese = '''
1. 我们收集的信息

《零点案件：侦探》收集以下信息：
- 游戏进度和保存数据
- 设备信息（用于兼容性）
- 匿名使用统计
- 应用内购买记录

2. 我们如何使用您的信息

我们使用收集的信息来：
- 保存您的游戏进度
- 改进游戏性能
- 提供客户支持
- 确保公平游戏体验

3. 数据安全

我们实施以下安全措施保护您的数据：
- 本地存储加密
- 安全的服务器连接
- 定期安全审计

4. 第三方服务

我们使用可信的第三方服务：
- 分析工具（Google Analytics）
- 云存储（Firebase）
- 支付处理（Google Play Store）

5. 儿童隐私

《零点案件》不适合13岁以下儿童使用。我们不会故意收集13岁以下儿童的个人信息。

6. 您的权利

您有权：
- 访问您的数据
- 删除您的数据
- 选择退出分析
- 就隐私问题联系我们

7. 数据保留

只要您的账户处于活跃状态，我们就会保留您的游戏数据。您可以随时要求删除。

8. 政策变更

我们可能会更新此政策。如有重大变更，我们将通过应用或电子邮件通知您。

9. 同意

使用《零点案件》即表示您同意本隐私政策。
''';

  // English Terms & Conditions
  final String _termsContent = '''
1. ACCEPTANCE OF TERMS

By installing and using Case Zero: Detective, you agree to these Terms and Conditions.

2. LICENSE GRANT

We grant you a limited, non-exclusive, non-transferable license to use the app for personal, non-commercial purposes.

3. USER CONDUCT

You agree not to:
- Cheat, hack, or exploit bugs
- Reverse engineer the app
- Share accounts or purchases
- Use the app for illegal purposes

4. IN-APP PURCHASES

- All purchases are final
- Prices may change without notice
- Virtual items have no real-world value

5. INTELLECTUAL PROPERTY

All game content, including characters, stories, and artwork, is owned by Case Zero Studios and protected by copyright.

6. ACCOUNT TERMINATION

We may terminate accounts for:
- Violating these terms
- Fraudulent activity
- Harassing other users

7. LIMITATION OF LIABILITY

Case Zero Studios is not liable for:
- Data loss or corruption
- In-app purchase issues
- Device compatibility problems
- Third-party service failures

8. DISCLAIMERS

The app is provided "as is" without warranties. We do not guarantee:
- Continuous availability
- Bug-free operation
- Data preservation

9. GOVERNING LAW

These terms are governed by the laws of the United States.

10. CHANGES TO TERMS

We may update these terms. Continued use after changes constitutes acceptance.

11. CONTACT

For questions about these terms, contact: legal@casezero.com

12. SEVERABILITY

If any provision is found invalid, the remaining terms remain in effect.

13. ENTIRE AGREEMENT

These terms constitute the entire agreement between you and Case Zero Studios regarding the app.
''';

  // Chinese Terms & Conditions (简体中文)
  final String _termsContentChinese = '''
1. 接受条款

安装并使用《零点案件：侦探》，即表示您同意本条款与条件。

2. 许可授予

我们授予您有限的、非独占的、不可转让的许可，供您为个人非商业目的使用本应用。

3. 用户行为

您同意不：
- 作弊、黑客攻击或利用漏洞
- 反向工程本应用
- 共享账户或购买内容
- 将应用用于非法目的

4. 应用内购买

- 所有购买均为最终购买
- 价格可能在不通知的情况下变更
- 虚拟物品无实际货币价值

5. 知识产权

所有游戏内容，包括角色、故事和艺术作品，均归零点案件工作室所有，并受版权保护。

6. 账户终止

我们可能因以下原因终止账户：
- 违反本条款
- 欺诈行为
- 骚扰其他用户

7. 责任限制

零点案件工作室不对以下情况负责：
- 数据丢失或损坏
- 应用内购买问题
- 设备兼容性问题
- 第三方服务故障

8. 免责声明

本应用按"现状"提供，无任何保证。我们不保证：
- 持续可用性
- 无漏洞操作
- 数据保存

9. 管辖法律

本条款受美国法律管辖。

10. 条款变更

我们可能会更新本条款。变更后继续使用即表示接受。

11. 联系方式

有关本条款的疑问，请联系：legal@casezero.com

12. 可分割性

如果任何条款被认定为无效，其余条款仍然有效。

13. 完整协议

本条款构成您与零点案件工作室之间关于本应用的完整协议。
''';

  // English About the App
  final String _aboutContent = '''
ABOUT CASE ZERO: DETECTIVE

Welcome to Case Zero: Detective, an immersive crime investigation game where you step into the shoes of a detective solving complex cases.

FEATURES:
• 5 Challenging Cases - Each with unique stories and puzzles
• Real Detective Work - Collect clues, interview suspects, solve puzzles
• Multiple Mini-Games - Memory match, code cracking, suspect selection
• Progress Tracking - Save your detective rank and achievements
• Atmospheric Design - Noir-inspired visuals and sound design
• Cloud Saves - Continue your investigation across devices

GAMEPLAY:
1. Crime Scene Investigation - Examine locations for clues
2. Evidence Analysis - Connect clues to build your case
3. Suspect Interrogation - Question characters to uncover lies
4. Puzzle Solving - Crack codes and solve mysteries
5. Final Accusation - Make your case and identify the culprit

DEVELOPED BY:
Case Zero Studios
A team of passionate developers and storytellers dedicated to creating engaging detective experiences.

TECHNOLOGY:
• Built with Flutter & Dart
• Firebase for cloud services
• Original soundtrack and artwork
• Regular updates with new cases

VERSION:
1.0.0 - Initial Release
• Cases 1-2: Vanished Necklace & Murder at Alley 17
• Full detective progression system
• Cloud save functionality
• Multiple language support

UPCOMING FEATURES:
• Cases 3-5 in development
• Multiplayer investigation mode
• Custom detective avatar
• Enhanced voice acting

SUPPORT:
We're committed to providing the best detective experience. If you encounter issues or have suggestions, please contact our support team.

Thank you for joining the investigation!
''';

  // Chinese About the App (简体中文)
  final String _aboutContentChinese = '''
关于《零点案件：侦探》

欢迎来到《零点案件：侦探》，这是一款沉浸式犯罪调查游戏，您将扮演侦探解决复杂案件。

主要功能：
• 5个挑战性案件 - 每个案件都有独特的故事和谜题
• 真实的侦探工作 - 收集线索、审问嫌疑人、解决谜题
• 多种迷你游戏 - 记忆匹配、破解密码、嫌疑人选择
• 进度追踪 - 保存您的侦探等级和成就
• 氛围设计 - 黑色电影风格的视觉和音效设计
• 云存档 - 跨设备继续您的调查

游戏玩法：
1. 犯罪现场调查 - 检查地点寻找线索
2. 证据分析 - 连接线索建立案件
3. 嫌疑人审讯 - 询问角色揭露谎言
4. 谜题解决 - 破解密码解开谜团
5. 最终指控 - 提出您的案件并识别罪犯

开发团队：
零点案件工作室
一支充满激情的开发者和故事讲述者团队，致力于创造引人入胜的侦探体验。

技术特点：
• 使用 Flutter & Dart 构建
• Firebase 用于云服务
• 原创配乐和艺术作品
• 定期更新新案件

版本：
1.0.0 - 初始版本
• 案件1-2：消失的项链 & 17号巷谋杀案
• 完整的侦探进度系统
• 云存档功能
• 多语言支持

即将推出的功能：
• 案件3-5开发中
• 多人调查模式
• 自定义侦探头像
• 增强的配音

技术支持：
我们致力于提供最佳的侦探体验。如果您遇到问题或有建议，请联系我们的支持团队。

感谢您加入调查！
''';
}