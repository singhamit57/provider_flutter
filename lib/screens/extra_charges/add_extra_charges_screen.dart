import 'package:flutter/material.dart';
import 'package:koibanda_provider_flutter/components/back_widget.dart';
import 'package:koibanda_provider_flutter/components/price_widget.dart';
import 'package:koibanda_provider_flutter/main.dart';
import 'package:koibanda_provider_flutter/models/add_extra_charges_model.dart';
import 'package:koibanda_provider_flutter/screens/extra_charges/components/add_extra_charge_dialog.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import '../../utils/configs.dart';

class AddExtraChargesScreen extends StatefulWidget {
  @override
  _AddExtraChargesScreenState createState() => _AddExtraChargesScreenState();
}

class _AddExtraChargesScreenState extends State<AddExtraChargesScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    afterBuildCreated(() async {
      openDialog();
    });
  }

  void openDialog() async {
    bool? res = await showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      barrierDismissible: false,
      builder: (_) {
        return AddExtraChargesDialog();
      },
    );

    if (res ?? false) {
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.lblAddExtraCharges,
        backWidget: BackWidget(),
        showBack: true,
        textColor: white,
        color: context.primaryColor,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: white),
            onPressed: () async {
              openDialog();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          if (chargesList.isEmpty)
            NoDataWidget(
              title: languages.noExtraChargesHere,
              imageWidget: EmptyStateWidget(),
            ),
          AnimatedListView(
            itemCount: chargesList.length,
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemBuilder: (_, i) {
              AddExtraChargesModel data = chargesList[i];

              return Container(
                padding: EdgeInsets.all(12),
                decoration: boxDecorationRoundedWithShadow(16,
                    backgroundColor: context.cardColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(languages.lblChargeName,
                            style: secondaryTextStyle()),
                        Text(data.title.validate(), style: boldTextStyle()),
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(languages.lblPrice, style: secondaryTextStyle()),
                        PriceWidget(
                            price: data.price.validate(),
                            color: textPrimaryColorGlobal,
                            isBoldText: false),
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(languages.quantity, style: secondaryTextStyle()),
                        Text(data.qty.toString().validate(),
                            style: boldTextStyle()),
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(languages.lblTotalCharges,
                            style: secondaryTextStyle()),
                        PriceWidget(
                            price:
                                '${data.price.validate() * data.qty.validate()}'
                                    .toDouble(),
                            size: 16,
                            color: textPrimaryColorGlobal,
                            isBoldText: true),
                      ],
                    ),
                    8.height,
                  ],
                ),
              ).paddingBottom(16);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: AppButton(
          text: languages.btnSave,
          color: context.primaryColor,
          onTap: () {
            showConfirmDialogCustom(
              context,
              title: languages.confirmationRequestTxt,
              primaryColor: primaryColor,
              positiveText: languages.lblYes,
              negativeText: languages.lblNo,
              onAccept: (BuildContext context) {
                if (chargesList.isNotEmpty) {
                  toast(languages.lblSuccessFullyAddExtraCharges);
                  finish(context, true);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
