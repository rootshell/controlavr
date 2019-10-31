/*
 * Copyright (C) 2019. Mikhail Kulesh
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details. You should have received a copy of the GNU General
 * Public License along with this program.
 */

import "package:flutter/material.dart";

import "../constants/Dimens.dart";
import "../constants/Drawables.dart";
import "../constants/Strings.dart";
import "../iscp/StateManager.dart";
import "../iscp/messages/FriendlyNameMsg.dart";
import "../iscp/messages/PowerStatusMsg.dart";
import "../iscp/messages/ReceiverInformationMsg.dart";
import "../utils/Logging.dart";
import "../widgets/CustomActivityTitle.dart";
import "../widgets/CustomDivider.dart";
import "../widgets/CustomImageButton.dart";
import "UpdatableView.dart";

enum AppTabs
{
    LISTEN, MEDIA, DEVICE, RC, RI
}

class AppBarView extends UpdatableView
{
    static const List<String> UPDATE_TRIGGERS = [
        StateManager.CONNECTION_EVENT,
        StateManager.ZONE_EVENT,
        ReceiverInformationMsg.CODE,
        FriendlyNameMsg.CODE,
        PowerStatusMsg.CODE
    ];

    static List<String> TAB_NAMES = [
        Strings.title_monitor,
        Strings.title_media,
        Strings.title_device,
        Strings.title_remote_control,
        Strings.title_remote_interface
    ];

    final TabController _tabController;
    final List<AppTabs> _tabs;

    AppBarView(final ViewContext viewContext, this._tabController, this._tabs) : super(viewContext, UPDATE_TRIGGERS);

    @override
    Widget createView(BuildContext context, VoidCallback updateCallback)
    {
        Logging.info(this, "rebuild widget");
        final ThemeData td = Theme.of(context);

        // Logo
        String subTitle = "";
        if (!state.isConnected)
        {
            subTitle = Strings.state_not_connected;
        }
        else
        {
            subTitle = state.receiverInformation.getDeviceName(configuration.friendlyNames);
            if (state.isExtendedZone)
            {
                if (subTitle.isNotEmpty)
                {
                    subTitle += "/";
                }
                subTitle += state.getActiveZoneInfo.getName;
            }
            if (!state.isOn)
            {
                subTitle += " (" + Strings.state_standby + ")";
            }
        }

        final double tabBarHeight = ActivityDimens.tabBarHeight(context);

        return AppBar(
            title: CustomActivityTitle(Strings.app_short_name, subTitle),
            actions: <Widget>[
                CustomImageButton.menu(Drawables.menu_power_standby, Strings.menu_power_power,
                    isEnabled: state.isConnected,
                    isSelected: !state.isOn,
                    onPressed: ()
                    {
                        Logging.info(this, "App bar menu: " + Strings.menu_power_power);
                        final PowerStatus p = state.isOn ? PowerStatus.STB : PowerStatus.ON;
                        stateManager.sendMessage(PowerStatusMsg.output(state.getActiveZone, p));
                    }),
            ],
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(tabBarHeight), // desired height of tabBar
                child: SizedBox(
                    height: tabBarHeight,
                    child: _buildTabs(td)))
        );
    }

    Widget _buildTabs(final ThemeData td)
    {
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                CustomDivider(color: td.primaryColorDark.withAlpha(175)),
                TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: td.bottomAppBarColor,
                    unselectedLabelColor: td.bottomAppBarColor.withAlpha(175),
                    tabs: _tabs.map((AppTabs tab)
                    {
                        final String tabName = TAB_NAMES[tab.index];
                        return Tab(text: tabName.toUpperCase());
                    }).toList(),
                )
            ]
        );
    }
}