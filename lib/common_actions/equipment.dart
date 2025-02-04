import 'dart:math';

import 'package:collection/collection.dart';
import 'package:lcs_new_age/common_display/common_display.dart';
import 'package:lcs_new_age/common_display/print_party.dart';
import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/engine/engine.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/gamestate/squad.dart';
import 'package:lcs_new_age/items/ammo.dart';
import 'package:lcs_new_age/items/armor.dart';
import 'package:lcs_new_age/items/item.dart';
import 'package:lcs_new_age/items/weapon.dart';
import 'package:lcs_new_age/items/weapon_type.dart';
import 'package:lcs_new_age/location/site.dart';
import 'package:lcs_new_age/utils/colors.dart';
import 'package:lcs_new_age/utils/interface_options.dart';

Future<void> equip(List<Item>? loot) async {
  if (activeSquad == null || loot == null) return;

  Site? site = activeSite;
  consolidateLoot(loot);
  consolidateLoot(site?.loot);

  int page = 0;
  String? errmsg;

  while (true) {
    erase();
    mvaddstrc(0, 0, lightGray, "Equip the Squad");
    printParty();

    if (errmsg != null) {
      move(8, 20);
      setColor(lightBlue);
      addstr(errmsg);
      setColor(lightGray);
      errmsg = null;
    }

    int x = 1, y = 10;
    for (int l = page * 18; l < loot.length && l < page * 18 + 18; l++) {
      String s = loot[l].equipTitle();

      if (loot[l].stackSize > 1 && !loot[l].type.isMoney) {
        s += " x${loot[l].stackSize}";
      }
      String let = letterAPlus(l - page * 18, capitalize: true);

      mvaddstr(y, x, "$let - $s");

      x += 26;
      if (x > 53) {
        x = 1;
        y++;
      }
    }

    //PAGE UP
    if (page > 0) {
      mvaddstr(17, 1, previousPageStr);
    }
    //PAGE DOWN
    if ((page + 1) * 18 < loot.length) {
      mvaddstr(17, 53, nextPageStr);
    }

    mvaddstrc(19, 1, lightGray, "Press a letter to equip a Liberal item");
    mvaddstr(20, 1,
        "Press a number to drop that Squad member's Conservative weapon");
    mvaddstr(21, 1, "S - Liberally Strip a Squad member");
    mvaddstr(22, 1, "Cursors - Increase or decrease ammo allocation");

    if (site != null && site.controller == SiteController.lcs) {
      setColorConditional(site.loot.isNotEmpty);
      mvaddstr(23, 1, "Y - Get things from ");
      addstr(site.getName(short: true));

      setColorConditional(loot.isNotEmpty);
      mvaddstr(23, 40, "Z - Stash things at ");
      addstr(site.getName(short: true));
    }

    mvaddstrc(24, 1, lightGray, "Enter - Done");

    int c = await getKey();

    bool increaseammo = (c == Key.upArrow), decreaseammo = (c == Key.downArrow);

    if ((c >= Key.a && c <= Key.r) || increaseammo || decreaseammo) {
      int slot = c - Key.a + page * 18;
      debugPrint(
          "Key: ${String.fromCharCode(c)} Slot: $slot LootLength: ${loot.length}");
      if (increaseammo || decreaseammo) {
        slot = -999;
      } else {
        if (slot < 0 || slot >= loot.length) continue; // Out of range.

        bool isWeapon = loot[slot] is Weapon;
        bool isArmor = loot[slot] is Armor;
        bool isAmmo =
            squad.any((m) => m.weapon.acceptableAmmo.contains(loot[slot].type));
        if (!isWeapon && !isArmor && !isAmmo) {
          errmsg = "You can't equip that.";
          continue;
        }
      }
      bool choice = true;
      if (squad.length == 1) choice = false;
      if (squad.length > 1) choice = true;
      c = Key.num1;
      if (choice) {
        move(8, 20);
        setColor(white);
        if (increaseammo) {
          addstr("Choose a Liberal squad member to receive ammo.");
        } else if (decreaseammo) {
          addstr("Choose a Liberal squad member to drop ammo.");
        } else {
          addstr("Choose a Liberal squad member to receive it.");
        }

        c = await getKey();
      }

      if (c >= Key.num1 && c <= Key.num6) {
        Creature? squaddie = activeSquad?.members.elementAtOrNull(c - Key.num1);

        if (squaddie != null) {
          if (decreaseammo) {
            Item? ammo = squaddie.spareAmmo;
            if (ammo != null) {
              loot.add(ammo.split(1));
              if (ammo.stackSize == 0) squaddie.spareAmmo = null;
            } else if (!squaddie.weapon.type.usesAmmo) {
              errmsg = "No ammo to drop!";
              continue;
            } else {
              errmsg = "No spare ammo!";
              continue;
            }
            consolidateLoot(loot, sort: false);
            continue;
          }
          if (increaseammo) {
            if (!squaddie.weapon.type.usesAmmo) {
              errmsg = "No ammo required!";
              continue;
            }
            slot = -1;
            for (int sl = 0; sl < loot.length; sl++) {
              if (squaddie.weapon.acceptableAmmo.contains(loot[sl].type)) {
                slot = sl;
                break;
              } else if (loot[sl] is Weapon &&
                  loot[sl].type == squaddie.weapon.type) {
                Weapon w = loot[sl] as Weapon;
                if (w.type.thrown) {
                  slot = sl;
                  break;
                }
              }
            }
            if (slot == -1) {
              errmsg = "No ammo available!";
              continue;
            }
          }
          int armok = squaddie.body.armok;

          if (loot[slot] is Weapon && armok > 0) {
            debugPrint(
                "Giving weapon ${loot[slot].type.name} to ${squaddie.name}");
            Weapon w = loot[slot] as Weapon;
            squaddie.giveWeapon(w, loot);

            if (page * 18 >= loot.length && page != 0) page--;
          } else if (loot[slot] is Armor) {
            debugPrint(
                "Giving armor ${loot[slot].type.name} to ${squaddie.name}");
            Armor a = loot[slot] as Armor;
            squaddie.giveArmor(a, loot);

            if (loot[slot].stackSize == 0) loot.removeAt(slot);

            if (page * 18 >= loot.length && page != 0) page--;
          } else if (squaddie.weapon.acceptableAmmo.contains(loot[slot].type) &&
              armok > 0) {
            int space = 9 - (squaddie.spareAmmo?.stackSize ?? 0);

            if (!squaddie.weapon.type.usesAmmo) {
              errmsg = "Can't carry ammo without a gun.";
              continue;
            } else if (!squaddie.weapon.acceptableAmmo
                .contains(loot[slot].type)) {
              errmsg = "That ammo doesn't fit.";
              continue;
            } else if (space < 1) {
              errmsg = "Can't carry any more ammo.";
              continue;
            } else {
              int amount = 1;
              if (loot[slot].stackSize > 1 && !increaseammo) {
                amount =
                    await promptAmount(0, min(loot[slot].stackSize, space));
              }

              squaddie.takeAmmo(loot[slot] as Ammo, loot, amount);

              if (loot[slot].stackSize < 1) loot.removeAt(slot);

              if (page * 18 >= loot.length && page != 0) page--;
            }
          }

          consolidateLoot(loot, sort: false);
        }
      }
      c = -1;
    } else if (c == Key.s) {
      bool choice = true;
      if (squad.isNotEmpty) choice = false;
      if (squad.length > 1) choice = true;
      int c = Key.num1;
      if (choice) {
        move(8, 20);
        setColor(white);
        addstr("Choose a Liberal squad member to strip down.");

        c = await getKey();
      }
      int index = c - Key.num1;
      if (index >= 0 && index < squad.length) {
        squad[index].strip(lootPile: loot);
        consolidateLoot(loot);
      }
    } else if (isBackKey(c)) {
      return;
    }

    if (site != null && site.controller == SiteController.lcs) {
      if (c == Key.y && site.loot.isNotEmpty) {
        await moveLoot(loot, site.loot);
      }
      if (c == Key.z && loot.isNotEmpty) {
        await moveLoot(site.loot, loot);
      }
    }

    if (c >= Key.num1 && c <= Key.num1 + squad.length - 1) {
      int p = c - Key.num1;
      squad[p].dropWeaponAndAmmo(lootPile: loot);
      consolidateLoot(loot, sort: false);
    }

    //PAGE UP
    if ((isPageUp(c) || c == Key.upArrow || c == Key.leftArrow) && page > 0) {
      page--;
    }
    //PAGE DOWN
    if ((isPageDown(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (page + 1) * 18 < loot.length) {
      page++;
    }
  }
}

/* lets you pick stuff to stash/retrieve from one location to another */
Future<void> moveLoot(List<Item> dest, List<Item> source) async {
  int page = 0;

  List<int> selected = [for (int i = 0; i < source.length; i++) 0];

  while (true) {
    erase();

    mvaddstrc(0, 0, lightGray, "Select Objects");

    printParty();

    int x = 1, y = 10;

    for (int l = page * 18; l < source.length && l < page * 18 + 18; l++) {
      setColor(selected[l] > 0 ? lightGreen : lightGray);

      String s = source[l].equipTitle();

      if (source[l].stackSize > 1) {
        s += " ";
        if (selected[l] > 0) {
          s += "${selected[l]}/";
        } else {
          s += "x";
        }
        s += source[l].stackSize.toString();
      }

      String str = letterAPlus(l - page * 18, capitalize: true);

      mvaddstr(y, x, "$str - $s");

      x += 26;
      if (x > 53) {
        x = 1;
        y++;
      }
    }

    //PAGE UP
    setColor(lightGray);
    if (page > 0) {
      mvaddstr(17, 1, previousPageStr);
    }
    //PAGE DOWN
    if ((page + 1) * 18 < source.length) {
      mvaddstr(17, 53, nextPageStr);
    }

    mvaddstrc(23, 1, lightGray, "Press a letter to select an item.");
    mvaddstr(24, 1, "Enter - Done");

    int c = await getKey();

    if (c >= Key.a && c <= Key.r) {
      int slot = c - Key.a + page * 18;

      if (slot >= 0 && slot < source.length) {
        if (selected[slot] > 0) {
          selected[slot] = 0;
        } else if (source[slot].stackSize > 1) {
          selected[slot] = await promptAmount(0, source[slot].stackSize);
        } else {
          selected[slot] = 1;
        }
      }
    }

    if (isBackKey(c)) break;

    //PAGE UP
    if ((isPageUp(c) || c == Key.upArrow || c == Key.leftArrow) && page > 0) {
      page--;
    }
    //PAGE DOWN
    if ((isPageDown(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (page + 1) * 18 < source.length) {
      page++;
    }
  }

  for (int l = source.length - 1; l >= 0; l--) {
    if (selected[l] > 0) {
      if (source[l].stackSize <= selected[l]) {
        dest.add(source[l]);
        source.removeAt(l);
      } else {
        Item newit = source[l].split(selected[l]);
        dest.add(newit);
      }
    }
  }

  // Avoid stuff jumping around the next time you equip.
  consolidateLoot(dest);
}

/* equipment - assign new bases to the equipment */
Future<void> equipmentBaseAssign() async {
  int p = 0, pageLoot = 0, pageLoc = 0, selectedbase = 0;
  bool sortbytype = false;
  List<Item> items = [];
  Map<Item, Site> siteFromItem = {};
  for (Site l in sites.where((l) => !l.siege.underSiege)) {
    for (Item l2 in l.loot) {
      items.add(l2);
      siteFromItem[l2] = l;
    }
  }
  if (items.isEmpty) return;

  List<Site> bases = sites
      .where((s) => s.controller == SiteController.lcs && !s.siege.underSiege)
      .toList();
  if (bases.isEmpty) return;

  while (true) {
    erase();

    setColor(lightGray);
    printFunds();

    mvaddstr(0, 0, "Moving Equipment");
    addHeader({4: "ITEM", 25: "CURRENT LOCATION", 51: "NEW LOCATION"});

    int y = 2;
    for (p = pageLoot * 19;
        p < items.length && p < pageLoot * 19 + 19;
        p++, y++) {
      mvaddstrc(
          y, 0, lightGray, "${letterAPlus(y - 2)} - ${items[p].equipTitle()}");
      mvaddstr(y, 25,
          siteFromItem[items[p]]!.getName(short: true, includeCity: true));
    }

    y = 2;
    for (p = pageLoc * 9; p < bases.length && p < pageLoc * 9 + 9; p++, y++) {
      if (p == selectedbase) {
        setColor(white);
      } else {
        setColor(lightGray);
      }
      mvaddstr(y, 51,
          "${y - 1} - ${bases[p].getName(short: true, includeCity: true)}");
    }

    mvaddstrc(22, 0, lightGray,
        "Press a Letter to assign a base.  Press a Number to select a base.");
    move(23, 0);
    if (sortbytype) {
      addstr("T to sort by location.");
    } else {
      addstr("T to sort by type.");
    }
    addstr("  Shift and a Number will move ALL items!");

    move(24, 0); // location for either viewing other base pages or loot pages
    if (bases.length > 9) {
      addstr(",. to view other base pages.");
      move(24,
          34); // we have base pages, so different location for viewing other loot pages
    }
    if (items.length > 19) {
      addstr(pageStr);
    }

    int c = await getKey();

    //PAGE UP (items)
    if ((isPageUp(c) || c == Key.upArrow || c == Key.leftArrow) &&
        pageLoot > 0) {
      pageLoot--;
    }
    //PAGE DOWN (items)
    if ((isPageDown(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (pageLoot + 1) * 19 < items.length) {
      pageLoot++;
    }

    //PAGE UP (locations)
    if (c == ','.codePoint && pageLoc > 0) pageLoc--;
    //PAGE DOWN (locations)
    if (c == '.'.codePoint && (pageLoc + 1) * 9 < bases.length) pageLoc++;

    //Toggle sorting method
    if (c == Key.t) {
      sortbytype = !sortbytype;
      if (sortbytype) {
        items.sort();
      } else {
        //Sort by location
        items.clear();
        for (Site l in sites.where((l) => !l.siege.underSiege)) {
          for (Item l2 in l.loot) {
            items.add(l2);
          }
        }
      }
    }

    if (c >= Key.a && c <= Key.s) {
      int p = pageLoot * 19 + c - Key.a;
      if (p < items.length) {
        // Search through the old base's stuff for this item
        for (int l2 = 0; l2 < siteFromItem[items[p]]!.loot.length; l2++) {
          // Remove it from that inventory and move it to the new one
          if (siteFromItem[items[p]]!.loot[l2] == items[p]) {
            siteFromItem[items[p]]!.loot.removeAt(l2);
            bases[selectedbase].loot.add(items[p]);
            siteFromItem[items[p]] = bases[selectedbase];
          }
        }
      }
    }
    if (c >= '1'.codePoint && c <= '9'.codePoint) {
      int p = pageLoc * 9 + c - '1'.codePoint;
      if (p < bases.length) selectedbase = p;
    }
    // Check if the player wants to move all items to a new location,
    // using Shift + a number key.
    String upnums = "!@#\$%^&*(";
    for (int upnumi = 0; upnumi < upnums.length; upnumi++) {
      if (c == upnums.codeUnitAt(upnumi)) {
        // Set base location
        int basechoice = pageLoc * 9 + upnumi;
        if (basechoice < bases.length) {
          selectedbase = basechoice;
          // Search through the old base's stuff for this item
          for (int p = 0; p < items.length; p++) {
            // Search through the old base's stuff for this item
            for (int l2 = 0; l2 < siteFromItem[items[p]]!.loot.length; l2++) {
              // Remove it from that inventory and move it to the new one
              if (siteFromItem[items[p]]!.loot[l2] == items[p]) {
                siteFromItem[items[p]]!.loot.removeAt(l2);
                bases[selectedbase].loot.add(items[p]);
                siteFromItem[items[p]] = bases[selectedbase];
              }
            }
          }
        }
      }
    }

    if (isBackKey(c)) break;
  }
}

void consolidateLoot(List<Item>? loot, {bool sort = true}) {
  if (loot == null) return;
  int l, l2;

  //PUT THINGS TOGETHER
  for (l = loot.length - 1; l >= 1; l--) {
    for (l2 = l - 1; l2 >= 0; l2--) {
      loot[l2].merge(loot[l]);
      if (loot[l].stackSize < 1) {
        loot.removeAt(l);
        break;
      }
    }
  }

  if (sort) loot.sort();
}

Future<int> promptAmount(int min, int max) async {
  printParty();
  mvaddstrc(8, 15, white, "     How many?          ");
  String amount = await enterName(8, 30, max.toString());
  int parsed = int.tryParse(amount) ?? 0;
  return parsed.clamp(min, max);
}

/* check if the squad has a certain weapon */
bool squadHasWeapon(Squad sq, WeaponType type) {
  return sq.members.any((p) => p.weapon.type == type) ||
      sq.loot.whereType<Weapon>().any((w) => w.type == type);
}
