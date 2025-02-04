/* base - review and reorganize liberals */
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:lcs_new_age/basemode/activities.dart';
import 'package:lcs_new_age/common_actions/equipment.dart';
import 'package:lcs_new_age/common_display/common_display.dart';
import 'package:lcs_new_age/common_display/print_creature_info.dart';
import 'package:lcs_new_age/creature/attributes.dart';
import 'package:lcs_new_age/creature/creature.dart';
import 'package:lcs_new_age/creature/gender.dart';
import 'package:lcs_new_age/creature/skills.dart';
import 'package:lcs_new_age/creature/sort_creatures.dart';
import 'package:lcs_new_age/engine/engine.dart';
import 'package:lcs_new_age/gamestate/game_state.dart';
import 'package:lcs_new_age/gamestate/squad.dart';
import 'package:lcs_new_age/justice/crimes.dart';
import 'package:lcs_new_age/location/location.dart';
import 'package:lcs_new_age/location/location_type.dart';
import 'package:lcs_new_age/location/siege.dart';
import 'package:lcs_new_age/location/site.dart';
import 'package:lcs_new_age/monthly/lcs_monthly.dart';
import 'package:lcs_new_age/politics/alignment.dart';
import 'package:lcs_new_age/utils/colors.dart';
import 'package:lcs_new_age/utils/interface_options.dart';
import 'package:lcs_new_age/utils/lcsrandom.dart';

Future<void> reviewAssetsAndFormSquads() async {
  int page = 0;

  while (true) {
    erase();

    setColor(lightGray);
    mvaddstr(0, 0, "Review your Liberals and Assemble Squads");
    addHeader({4: "SQUAD NAME", 31: "LOCATION", 51: "ACTIVITY"});

    int active = 0, hostages = 0, hospital = 0;
    int justice = 0, sleepers = 0, dead = 0, away = 0, equipment = 0;
    int y = 2;
    for (Creature p in pool) {
      if (p.isActiveLiberal) active++; // Active Liberals
      if (p.align != Alignment.liberal && p.alive) hostages++; // Hostages
      if (p.clinicMonthsLeft > 0 && p.alive) hospital++; // Hospital
      if (p.imprisoned) justice++; // Justice System
      if (p.sleeperAgent) sleepers++; // Sleepers
      if (!p.alive) dead++; // The Dead
      if ((p.vacationDaysLeft > 0 || p.hidingDaysLeft > 0) && p.alive) {
        away++; // Away
      }
    }
    for (Site l in sites) {
      consolidateLoot(l.loot);
      if (!l.siege.underSiege) {
        equipment += l.loot.length; // Review and Move Equipment}
      }
    }

    for (int p = page * 19;
        p < squads.length + 7 + 1 && p < page * 19 + 19;
        p++, y++) {
      if (p < squads.length) {
        bool active = activeSquad == squads[p];
        setColor(active ? white : lightGray);
        mvaddchar(y, 0, letterAPlus(y - 2));
        addstr(" - ");
        addstr(squads[p].name);

        if (squads[p].members.isNotEmpty &&
            squads[p].members[0].location != null) {
          Location? loc = squads[p].members[0].location;
          if (loc != null) {
            if (loc is Site && loc.siege.underSiege) {
              if (loc.siege.underAttack) {
                setColor(active ? red : darkRed);
              } else {
                setColor(active ? yellow : brown);
              }
            }
            mvaddstr(y, 31, loc.getName(short: true, includeCity: true));
            setColor(active ? white : lightGray);
          }
        }

        if (squads[p].members.isNotEmpty) {
          String str = squads[p].activity.description;
          setColor(squads[p].activity.color);
          if (squads[p].activity.type == ActivityType.none) {
            bool haveact = false, multipleact = false;
            for (int p2 = 0; p2 < squads[p].members.length; p2++) {
              String str2 = squads[p].members[p2].activity.description;
              setColor(squads[p].members[p2].activity.color);
              if (haveact && str != str2) multipleact = true;
              str = str2;
              haveact = true;
            }
            if (multipleact) {
              str = "Acting Individually";
              setColor(white);
            }
          }
          mvaddstr(y, 51, str);
        }
      } else if (p == squads.length) {
        mvaddstrc(y, 0, lightGreen, "1 - Active Liberals ($active)");
      } else if (p == squads.length + 1) {
        mvaddstrc(y, 0, red, "2 - Hostages ($hostages)");
      } else if (p == squads.length + 2) {
        mvaddstrc(y, 0, white, "3 - Hospital ($hospital)");
      } else if (p == squads.length + 3) {
        mvaddstrc(y, 0, yellow, "4 - Justice System ($justice)");
      } else if (p == squads.length + 4) {
        mvaddstrc(y, 0, purple, "5 - Sleepers ($sleepers)");
      } else if (p == squads.length + 5) {
        mvaddstrc(y, 0, darkGray, "6 - The Dead ($dead)");
      } else if (p == squads.length + 6) {
        mvaddstrc(y, 0, blue, "7 - Away ($away)");
      } else if (p == squads.length + 7) {
        mvaddstrc(
            y, 0, lightBlue, "8 - Review and Move Equipment ($equipment)");
      } else {
        break;
      }
    }

    setColor(lightGray);
    mvaddstr(21, 0, "Press V to Inspect Liberal finances.");
    move(22, 0);
    addstr("Press a Letter to select a squad.  1-7 to view Liberal groups.");
    move(23, 0);
    addstr(pageStr);
    addstr(".  Press U to Promote Liberals.");
    move(24, 0);
    addstr(
        "Press Z to Assemble a New Squad.  Press T to Assign New Bases to the Squadless.");

    int c = await getKey();

    if ((isPageDown(c) || c == Key.upArrow || c == Key.leftArrow) && page > 0) {
      page--;
    }
    if ((isPageUp(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (page + 1) * 19 < squads.length + 7) {
      page++;
    }

    if (isBackKey(c)) return;

    if (c >= Key.a && c <= Key.s) {
      int sq = page * 19 + c - Key.a;
      if (sq < squads.length && sq >= 0) {
        if (squads[sq] == activeSquad) {
          await assembleSquad(squads[sq]);
        } else {
          activeSquad = squads[sq];
        }
      }
    }
    if (c >= '1'.codePoint && c <= '7'.codePoint) {
      await reviewMode(ReviewMode.values[c - '1'.codePoint]);
    }
    if (c == '8'.codePoint) {
      await equipmentBaseAssign();
    }
    if (c == Key.z) {
      await assembleSquad(null);
      if (activeSquad == null && squads.isNotEmpty) {
        activeSquad = squads[squads.length - 1];
      }
    }
    if (c == Key.t) await assignNewBasesToTheSquadless();
    if (c == Key.u) await promoteliberals();
    if (c == Key.v) await fundReport(false);
  }
}

enum ReviewMode {
  liberals,
  hostages,
  clinic,
  justice,
  sleepers,
  dead,
  away;

  SortingScreens get sortMode {
    return switch (this) {
      liberals => SortingScreens.liberals,
      hostages => SortingScreens.hostages,
      clinic => SortingScreens.clinic,
      justice => SortingScreens.justice,
      sleepers => SortingScreens.sleepers,
      dead => SortingScreens.dead,
      away => SortingScreens.away,
    };
  }
}

Future<void> reviewMode(ReviewMode mode) async {
  List<Creature> temppool = [];
  Creature? swap;
  int swapPos = 0;

  for (Creature p in pool) {
    switch (mode) {
      case ReviewMode.liberals:
        if (p.isActiveLiberal) temppool.add(p);
      case ReviewMode.hostages:
        if (p.align != Alignment.liberal && p.alive) temppool.add(p);
      case ReviewMode.clinic:
        if (p.clinicMonthsLeft > 0 && p.alive) temppool.add(p);
      case ReviewMode.justice:
        if (p.imprisoned) temppool.add(p);
      case ReviewMode.sleepers:
        if (p.sleeperAgent) temppool.add(p);
      case ReviewMode.dead:
        if (!p.alive) temppool.add(p);
      case ReviewMode.away:
        if ((p.vacationDaysLeft > 0 || p.hidingDaysLeft > 0) && p.alive) {
          temppool.add(p);
        }
    }
  }

  if (temppool.isEmpty) return;

  sortLiberals(temppool, mode.sortMode);

  int page = 0;

  while (true) {
    erase();

    setColor(lightGray);
    move(0, 0);
    switch (mode) {
      case ReviewMode.liberals:
        addstr("Active Liberals");
      case ReviewMode.hostages:
        addstr("Conservative Automatons in Captivity");
      case ReviewMode.clinic:
        addstr("Liberals in the Medical System");
      case ReviewMode.justice:
        addstr("Liberals in the Justice System");
      case ReviewMode.sleepers:
        addstr("Sleepers");
      case ReviewMode.dead:
        addstr("Liberal Martyrs and Dead Bodies");
      case ReviewMode.away:
        addstr("Liberals that are Away");
    }
    addHeader({
      4: "CODE NAME",
      25: "SKILL",
      33: "HEALTH",
      42: "LOCATION",
      57: switch (mode) {
        ReviewMode.liberals => "SQUAD / ACTIVITY",
        ReviewMode.hostages => "DAYS IN CAPTIVITY",
        ReviewMode.justice => "MONTHS LEFT",
        ReviewMode.clinic => "PROGNOSIS",
        ReviewMode.sleepers => "PROFESSION",
        ReviewMode.dead => "DAYS SINCE PASSING",
        ReviewMode.away => "DAYS UNTIL RETURN",
      }
    });

    int y = 2;
    for (int p = page * 19; p < temppool.length && p < page * 19 + 19; p++) {
      Creature tempp = temppool[p];
      setColor(lightGray);
      mvaddchar(y, 0, letterAPlus(y - 2));
      addstr(" - ");
      addstr(tempp.name);

      bool bright = false;
      int skill = 0;
      for (Skill sk in Skill.values) {
        skill += tempp.skill(sk);
        if (tempp.skillXP(sk) >= 100 + (10 * tempp.skill(sk)) &&
            tempp.skill(sk) < tempp.skillCap(sk)) {
          bright = true;
        }
      }

      setColor(bright ? white : lightGray);

      move(y, 25);
      addstr(skill.toString());

      printHealthStat(y, 33, tempp, small: true);

      if (mode == ReviewMode.justice) {
        setColor(yellow);
      } else {
        setColor(lightGray);
      }
      move(y, 42);
      addstr(tempp.location?.getName(short: true, includeCity: true) ?? "Away");

      move(y, 57);
      switch (mode) {
        case ReviewMode.liberals:
          bool usepers = true;
          if (tempp.squadId != null) {
            Squad? sq = tempp.squad;
            if (sq != null) {
              if (sq.activity.type != ActivityType.none) {
                setColor(lightGreen);
                addstr("SQUAD");
                usepers = false;
              }
            }
          }
          if (usepers) {
            // Let's add some color here...
            setColor(tempp.activity.color);
            addstr(tempp.activity.description);
          }
        case ReviewMode.hostages:
          setColor(purple);
          addstr(tempp.daysSinceJoined.toString());
          addstr(" ");
          if (tempp.daysSinceJoined > 1) {
            addstr("Days");
          } else {
            addstr("Day");
          }
        case ReviewMode.justice:
          if (tempp.site?.type == SiteType.prison) {
            if (tempp.deathPenalty && tempp.sentence != 0) {
              setColor(red);
              addstr("DEATH ROW: ");
              addstr(tempp.sentence.toString());
              addstr(" ");
              if (tempp.sentence > 1) {
                addstr("Months");
              } else {
                addstr("Month");
              }
            } else if (tempp.sentence <= -1) {
              setColor(lightGray);
              if (tempp.sentence < -1) {
                addstr("${-tempp.sentence}");
                addstr(" Life Sentences");
              } else {
                addstr("Life Sentence");
              }
            } else if (tempp.sentence != 0) {
              setColor(yellow);
              addstr(tempp.sentence.toString());
              addstr(" ");
              if (tempp.sentence > 1) {
                addstr("Months");
              } else {
                addstr("Month");
              }
            }
          } else {
            setColor(darkGray);
            addstr("———————"); // 7 characters
          }
        case ReviewMode.clinic:
          setColor(lightBlue);
          addstr("Out in ");
          addstr(tempp.clinicMonthsLeft.toString());
          addstr(" ");
          if (tempp.clinicMonthsLeft > 1) {
            addstr("Months");
          } else {
            addstr("Month");
          }
        case ReviewMode.sleepers:
          setColor(tempp.align.color);
          addstr(tempp.type.name);
        case ReviewMode.dead:
          setColor(purple);
          addstr(tempp.daysSinceDeath.toString());
          addstr(" ");
          if (tempp.daysSinceDeath > 1) {
            addstr("Days");
          } else {
            addstr("Day");
          }
        case ReviewMode.away:
          setColor(lightBlue);
          if (tempp.hidingDaysLeft != -1) {
            addstr("${tempp.vacationDaysLeft + tempp.hidingDaysLeft} ");
            if (tempp.vacationDaysLeft + tempp.hidingDaysLeft > 1) {
              addstr("Days");
            } else {
              addstr("Day");
            }
          } else {
            addstr("<No Contact>");
          }
      }

      y++;
    }

    setColor(lightGray);
    move(22, 0);
    addstr("Press a Letter to View Status.        Z - ");
    if (swap != null) {
      addstr("Place ");
      addstr(swap.name);
    } else {
      addstr("Reorder Liberals");
    }
    move(23, 0);
    addstr(pageStr);
    addstr(" T to sort people.");

    int c = await getKey();

    //PAGE UP
    if ((isPageUp(c) || c == Key.upArrow || c == Key.leftArrow) && page > 0) {
      page--;
    }
    //PAGE DOWN
    if ((isPageDown(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (page + 1) * 19 < temppool.length) {
      page++;
    }

    if (c >= Key.a && c <= Key.s) {
      int p = page * 19 + (c - Key.a);
      if (p < temppool.length) {
        int page = 0;
        //const int pagenum=2;
        while (true) {
          Creature tempp = temppool[p];
          erase();

          move(0, 0);
          if (tempp.align != Alignment.liberal) {
            setColor(red);
            addstr("Profile of an Automaton");
          } else {
            setColor(lightGreen);
            addstr("Profile of a Liberal");
          }

          if (page == 0) printFullCreatureStats(tempp);
          if (page == 1) printFullCreatureSkills(tempp);
          if (page == 2) printFullCreatureCrimes(tempp);

          // Add removal of squad members member
          move(22, 0);

          if (tempp.isActiveLiberal &&
              tempp.hireId != null) // If alive and not own boss? (suicide?)
          {
            addstr("R - Remove member");
            Creature? boss = pool.firstWhereOrNull((p) => p.id == tempp.hireId);
            if (boss != null && boss.location == tempp.location) {
              addstr("         K - Kill member");
            }
          }

          move(23, 0);

          if (tempp.align == Alignment.conservative) {
            addstr("Press N to change this Automaton's Code Name");
          } else {
            addstr("N - Change Name");
            mvaddstr(23, 26, "G - Change Gender");
          }
          if (temppool.length > 1) addstr("    LEFT/RIGHT - View Others");
          move(24, 0);
          addstr("Press any other key to continue the Struggle");
          addstr("    UP/DOWN  - More Info");

          int c = await getKey();

          if (temppool.length > 1 &&
              ((c == Key.leftArrow) || (c == Key.rightArrow))) {
            int sx = 1;
            if (c == Key.leftArrow) sx = -1;
            p = (p + temppool.length + sx) % temppool.length;
            continue;
          }

          if (c == Key.downArrow) {
            page++;
            if (page > 2) page = 0;
            continue;
          }

          if (c == Key.upArrow) {
            page--;
            if (page < 0) page = 2;
            continue;
          }

          if (c == Key.n) {
            setColor(lightGray);
            mvaddstr(23, 0,
                "What is the new code name?                                                      "); // 80 characters
            mvaddstr(24, 0,
                "                                                                                "); // 80 spaces

            tempp.name = await enterName(24, 0, tempp.name);
          } else if (c == Key.g && tempp.align == Alignment.liberal) {
            List<Gender> genders = [
              Gender.male,
              Gender.female,
              Gender.nonbinary
            ];
            int index;
            if (genders.contains(tempp.gender)) {
              index = genders.indexOf(tempp.gender);
            } else {
              index = 0;
            }
            tempp.gender = genders[(index + 1) % genders.length];
          } else if (c == Key.r &&
              tempp.isActiveLiberal &&
              tempp.hireId != null) // If alive and not own boss?
          {
            Creature boss = pool.firstWhere((p) => p.id == tempp.hireId);

            eraseArea(startY: 22);

            move(22, 0);
            setColor(lightGray);
            addstr(
                "Do you want to permanently release this squad member from the LCS?");

            move(23, 0);
            addstr("If the member has low heart they may go to the police.");

            move(24, 0);
            addstr("  C - Confirm       Any other key to continue");

            int c = await getKey();

            if (c == Key.c) {
              eraseArea(startY: 22);
              // Release squad member
              move(22, 0);
              addstr(tempp.name);
              addstr(" has been released.");

              await getKey();

              // Chance of member going to police if boss has criminal record and
              // if they have low heart
              if (tempp.attribute(Attribute.heart) <
                      tempp.attribute(Attribute.wisdom) - lcsRandom(5) &&
                  boss.isCriminal) {
                setColor(lightBlue);
                move(22, 0);
                addstr("A Liberal friend tips you off on ");
                addstr(tempp.name);
                addstr("'s whereabouts.");
                move(24, 0);
                addstr(
                    "The Conservative traitor has ratted you out to the police, and sworn");
                move(25, 0);
                addstr("to testify against ");
                addstr(boss.name);
                addstr(" in court.");
                await getKey();

                criminalize(boss, Crime.racketeering);
                boss.confessions++;

                if (boss.heat > 20) {
                  boss.base?.siege.timeUntilCops = 3;
                } else {
                  boss.heat += 10;
                }
              }

              // Remove squad member
              tempp.squad = null;
              cleanGoneSquads();

              pool.remove(tempp);
              return reviewMode(mode);
            }
          } else if (c == Key.k &&
              tempp.isActiveLiberal &&
              tempp.hireId != null) // If alive and not own boss?
          {
            // Kill squad member
            Creature boss = pool.firstWhere((p) => p.id == tempp.hireId);
            if (boss.location != tempp.location) break;

            eraseArea(startY: 22);

            move(22, 0);
            setColor(lightGray);
            addstr("Confirm you want to have ");
            addstr(boss.name);
            addstr(" kill this squad member?");
            move(23, 0);
            addstr("Killing your squad members is Not a Liberal Act.");
            move(24, 0);
            addstr("C - Confirm                Any other key to continue");

            int c = await getKey();

            if (c == Key.c) {
              eraseArea(startY: 22);
              tempp.die();
              cleanGoneSquads();
              stats.kills++;

              move(22, 0);
              addstr(boss.name);
              addstr(" executes ");
              addstr(tempp.name);
              addstr(" by ");
              switch (lcsRandom(3)) {
                case 0:
                  addstr("strangling to death.");
                case 1:
                  addstr("beating to death.");
                case 2:
                  addstr("cold execution.");
              }

              await getKey();

              move(22, 0);
              if (lcsRandom(boss.rawAttributes[Attribute.heart]!) >
                  lcsRandom(3)) {
                eraseLine(22);
                setColor(lightGreen);
                addstr(boss.name);
                addstr(" feels sick to the stomach afterward and");
                boss.heartDamage++;
                move(23, 0);
                switch (lcsRandom(4)) {
                  case 0:
                    addstr("throws up in a trash can.");
                  case 1:
                    addstr("gets drunk, eventually falling asleep.");
                  case 2:
                    addstr("curls up in a ball, crying softly.");
                  case 3:
                    addstr("shoots up and collapses in a heap on the floor.");
                }
                move(24, 0);
                addstr(boss.name);
                addstr(" has lost heart.");
                await getKey();
              } else if (lcsRandom(3) == 0) {
                setColor(lightBlue);
                addstr(boss.name);
                addstr(" grows colder.");
                boss.adjustAttribute(Attribute.wisdom, 1);
                move(24, 0);
                addstr(boss.name);
                addstr(" has gained wisdom.");
                await getKey();
              }
            }
          } else {
            break;
          }
        }
      }
    }

    if (c == Key.t) {
      await sortingPrompt(mode.sortMode);
      sortLiberals(temppool, mode.sortMode);
    }

    // Reorder squad
    if (c == Key.z) {
      if (temppool.length <= 1) continue;

      eraseArea(startY: 22);

      move(22, 8);
      setColor(white);
      addstr("Choose squad member to replace ");

      if (swap == null) {
        int c = await getKey();

        if (isBackKey(c)) break;

        if (c < Key.a || c > Key.s) continue; // Not within correct range

        // Get first member to swap
        int p = page * 19 + c - Key.a;

        if (p < temppool.length) swap = temppool[swapPos = p];
      } else {
        // non-null swap
        addstr(swap.name);
        addstr(" with");

        int c = await getKey();

        if (isBackKey(c)) break;

        if (c < Key.a || c > Key.s) continue; // Not within correct range

        Creature? swap2;

        int p = page * 19 + c - Key.a;

        if (p < temppool.length && temppool[p] != swap) {
          swap2 = temppool[p];

          for (int i = 0; i < pool.length; i++) {
            if (pool[i].id == swap.id) {
              pool.removeAt(i);
              break;
            }
          }

          for (int i = 0; i < pool.length; i++) {
            if (pool[i].id == swap2.id) {
              pool.insert(i + (swapPos < p ? 1 : 0), swap);
              break;
            }
          }

          temppool.removeAt(swapPos);
          temppool.insert(p, swap);

          swap = null;
        }
      }
    }

    if (isBackKey(c)) break;
  }
}

/* base - review - assemble a squad */
Future<void> assembleSquad(Squad? cursquad) async {
  Site? culloc;
  int p;
  if (cursquad != null) culloc = cursquad.site;

  bool newsquad = false;
  if (cursquad == null) {
    cursquad = Squad();
    newsquad = true;
  }

  List<Creature> temppool = pool
      .where((p) => p.isActiveLiberal && (p.site == culloc || culloc == null))
      .toList();

  int page = 0, partysize;

  while (true) {
    partysize = cursquad.members.length;

    erase();

    setColor(lightGray);
    move(0, 0);
    if (partysize < 6) {
      addstr("Assemble the squad!");
    } else {
      addstr("The squad is full.");
    }

    if (newsquad) {
      move(0, 71);
      addstr("New Squad");
    } else {
      move(0, 73 - cursquad.name.length);
      addstr("Squad: ");
      addstr(cursquad.name);
    }

    addHeader({4: "CODE NAME", 25: "SKILL", 33: "HEALTH", 50: "PROFESSION"});

    int y = 2;
    for (p = page * 19; p < temppool.length && p < page * 19 + 19; p++) {
      Creature tempp = temppool[p];
      setColor(lightGray);
      mvaddchar(y, 0, letterAPlus(y - 2));
      addstr(" - ");
      addstr(tempp.name);

      bool bright = false;
      int skill = 0;
      for (Skill sk in Skill.values) {
        skill += tempp.skill(sk);
        if (tempp.skillXP(sk) >= 100 + (10 * tempp.skill(sk)) &&
            tempp.skill(sk) < tempp.skillCap(sk)) {
          bright = true;
        }
      }

      setColor(bright ? white : lightGray);

      move(y, 25);
      addstr(skill.toString());

      printHealthStat(y, 33, tempp);

      if (tempp.squadId == cursquad.id) {
        setColor(lightGreen);
        move(y, 75);
        addstr("SQUAD");
      } else if (tempp.squadId != null) {
        setColor(yellow);
        move(y, 75);
        addstr("SQUAD");
      } else if (cursquad.members.isNotEmpty) {
        if (cursquad.members[0].location != tempp.location) {
          setColor(darkGray);
          move(y, 75);
          addstr("AWAY");
        }
      }

      setColor(tempp.align.color);
      move(y, 50);
      addstr(tempp.type.name);
      y++;
    }

    setColor(lightGray);
    move(22, 0);
    addstr("Press a Letter to add or remove a Liberal from the squads.");
    move(23, 0);
    addstr(pageStr);
    move(23, 50);
    addstr("V - View a Liberal");
    move(24, 0);
    if (partysize > 0) {
      addstr("Enter - The squad is ready.");
    } else {
      addstr("Enter - I need no squad!");
    }
    if (partysize > 0) {
      setColor(lightGray);
    } else {
      setColor(darkGray);
    }
    move(24, 40);
    addstr("9 - Dissolve the squad.");

    int c = await getKey();

    //PAGE UP
    if ((isPageUp(c) || c == Key.upArrow || c == Key.leftArrow) && page > 0) {
      page--;
    }
    //PAGE DOWN
    if ((isPageDown(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (page + 1) * 19 < temppool.length) {
      page++;
    }

    if (c >= Key.a && c <= Key.s) {
      int p = page * 19 + c - Key.a;
      if (p < temppool.length) {
        Creature tempp = temppool[p];
        bool conf = true;
        if (cursquad.members.isNotEmpty) {
          if (cursquad.members[0].location != tempp.location) {
            eraseArea(startY: 22);
            setColor(red);
            mvaddstrCenter(
                23, "Liberals must be in the same location to form a squads.");

            await getKey();

            conf = false;
          }
        }
        if (!tempp.canWalk && !tempp.hasWheelchair) {
          eraseArea(startY: 22);
          setColor(red);
          mvaddstrCenter(23, "Squad Liberals must be able to move around.");

          await getKey();

          conf = false;
        }
        if (conf) {
          if (tempp.squadId == cursquad.id) {
            tempp.squad = null;
            cursquad.members.remove(tempp);
          } else if (partysize < 6) {
            tempp.squad = cursquad;
          }
        }
      }
    }
    if (c == Key.v) {
      eraseArea(startY: 22);
      move(22, 0);
      setColor(white);
      addstr("Press a Letter to view Liberal details.");
      int c2 = await getKey();
      if (c2 >= Key.a && c2 <= Key.s) {
        int p = page * 19 + c2 - Key.a;
        if (p < temppool.length) {
          Creature tempp = temppool[p];
          //Create a temporary squad from which to view this character - even if they already have a squad.
          Squad? oldactiveSquad = activeSquad;
          Squad? oldSquad = tempp.squad;
          //create a temp squad containing just this liberal
          activeSquad = Squad()..name = "Temporary Squad";
          tempp.squad = activeSquad;
          await fullCreatureInfoScreen(tempp);
          tempp.squad = oldSquad;
          activeSquad = oldactiveSquad;
        }
      }
    }
    if (isBackKey(c)) {
      break;
    }
    if (c == '9'.codePoint) {
      for (int p = cursquad.members.length - 1; p >= 0; p--) {
        cursquad.members[p].squad = null;
      }
    }
  }

  //FINALIZE NEW SQUADS
  bool hasmembers = cursquad.members.isNotEmpty;

  if (newsquad) {
    if (hasmembers) {
      eraseArea(startY: 22);
      move(23, 0);
      addstr("What shall we designate this Liberal squad?");
      cursquad.name = await enterName(24, 0, "The Liberal Crime Squad");

      squads.add(cursquad);
    }
  }

  //NUKE ALL EMPTY SQUADS
  cleanGoneSquads();
}

/* base - review - assign new bases to the squadless */
Future<void> assignNewBasesToTheSquadless() async {
  int pageLib = 0, pageLoc = 0, selectedbase = 0;
  List<Creature> temppool =
      pool.where((p) => p.isActiveLiberal && p.squad == null).toList();

  if (temppool.isEmpty) return;

  List<Site> temploc = sites
      .where((l) =>
          l.controller == SiteController.lcs &&
          l.siege.activeSiegeType == SiegeType.none)
      .toList();
  if (temploc.isEmpty) return;

  while (true) {
    erase();

    setColor(lightGray);
    printFunds();

    move(0, 0);
    addstr("New Bases for Squadless Liberals");
    addHeader({4: "CODE NAME", 25: "CURRENT BASE", 51: "NEW BASE"});

    int y = 2;
    for (int p = pageLib * 19;
        p < temppool.length && p < pageLib * 19 + 19;
        p++, y++) {
      Creature tempp = temppool[p];
      // Red name if location under siege
      if (tempp.base == tempp.location &&
          tempp.base?.siege.underSiege == true) {
        setColor(red);
      } else if (multipleCityMode &&
          tempp.base?.city != temploc[selectedbase].city) {
        setColor(darkGray);
      } else {
        setColor(lightGray);
      }
      mvaddchar(y, 0, letterAPlus(y - 2));
      addstr(" - ${tempp.name}");

      mvaddstr(
          y, 25, tempp.base?.getName(short: true, includeCity: true) ?? "Away");
      if (tempp.base?.siege.underSiege == true) {
        addstr(" <Under Siege>");
      }
    }

    y = 2;
    for (int p = pageLoc * 9;
        p < temploc.length && p < pageLoc * 9 + 9;
        p++, y++) {
      if (p == selectedbase) {
        setColor(white);
      } else {
        setColor(lightGray);
      }
      mvaddchar(y, 51, (y - 1).toString());
      addstr(" - ");
      addstr(temploc[p].getName(short: true, includeCity: true));
    }

    setColor(lightGray);
    mvaddstr(21, 0,
        "Press a Letter to assign a Base.  Press a Number to select a Base.");
    mvaddstr(
        22, 0, "Liberals must be moved in squads to transfer between cities.");
    if (temppool.length > 19) {
      move(23, 0);
      addstr(pageStr);
    }
    if (temploc.length > 9) {
      move(24, 0);
      addstr(",. to view other Base pages.");
    }

    int c = await getKey();

    //PAGE UP (people)
    if ((isPageUp(c) || c == Key.upArrow || c == Key.leftArrow) &&
        pageLib > 0) {
      pageLib--;
    }
    //PAGE DOWN (people)
    if ((isPageDown(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (pageLib + 1) * 19 < temppool.length) {
      pageLib++;
    }

    //PAGE UP (locations)
    if (c == ','.codePoint && pageLoc > 0) pageLoc--;
    //PAGE DOWN (locations)
    if (c == '.'.codePoint && (pageLoc + 1) * 9 < temploc.length) pageLoc++;

    if (c >= Key.a && c <= Key.s) {
      int p = pageLib * 19 + c - Key.a;
      if (p >= temppool.length) continue;
      Creature tempp = temppool[p];

      // Assign new base, IF the selected letter is a liberal, AND the Liberal is not under siege or in a different city
      if (!(tempp.base == tempp.location &&
              tempp.base?.siege.underSiege == true) &&
          !(multipleCityMode &&
              tempp.base?.city != temploc[selectedbase].city)) {
        tempp.base = temploc[selectedbase];
      }
    }
    if (c >= '1'.codePoint && c <= '9'.codePoint) {
      int p = pageLoc * 9 + c - '1'.codePoint;
      if (p < temploc.length) selectedbase = p;
    }

    if (isBackKey(c)) break;
  }
}

// prints a formatted name, used by promoteliberals
void printname(Creature cr) {
  Color? bracketcolor;
  Color namecolor;

  if (cr.hidingDaysLeft != 0) bracketcolor = black;

  // Determine bracket color, if any, based on location
  switch (cr.site?.type) {
    case SiteType.policeStation:
    case SiteType.courthouse:
      if (!cr.sleeperAgent) bracketcolor = yellow;
    case SiteType.prison:
      if (!cr.sleeperAgent) bracketcolor = red;
    default:
      break;
  }

  // Determine name color, based on recruitment style
  if (cr.seduced) {
    namecolor = purple;
  } else if (cr.brainwashed) {
    namecolor = yellow;
  } else {
    namecolor = white;
  }

  // Add brackets
  if (bracketcolor != null) addstrc(bracketcolor, "[");
  if (cr.sleeperAgent) addstrc(blue, "[");
  // Add name
  addstrc(namecolor, cr.name);
  // Closing brackets
  if (cr.sleeperAgent) addstrc(blue, "]");
  if (bracketcolor != null) addstrc(bracketcolor, "]");

  setColor(lightGray);
}

/* base - review - promote liberals */
Future<void> promoteliberals() async {
  const int pageLength = 19;
  List<Creature> temppool =
      pool.where((p) => p.alive && p.align == Alignment.liberal).toList();
  List<int> level = [];

  if (temppool.isEmpty) return;

  //SORT
  sortbyhire(temppool, level);
  debugPrint(temppool.toString());

  //PROMOTE
  int page = 0;

  while (true) {
    erase();

    setColor(lightGray);
    printFunds();

    move(0, 0);
    addstr("Promote the Elite Liberals");
    addHeader(
        {4: "CODE NAME", 27: "CURRENT CONTACT", 54: "CONTACT AFTER PROMOTION"});

    int y = 2;

    for (int p = page * pageLength;
        p < temppool.length && p < page * pageLength + pageLength;
        p++) {
      Creature tempp = temppool[p];
      setColor(lightGray);
      mvaddchar(y, 0, letterAPlus(y - 2));
      addstr(" - ");

      move(y, 27);
      int p2 = 0;

      for (p2 = 0; p2 < pool.length; p2++) {
        int p3 = 0;
        if (pool[p2].alive && pool[p2].id == tempp.hireId) {
          printname(pool[p2]);

          move(y, 54);
          for (p3 = 0; p3 < pool.length; p3++) {
            if (pool[p3].alive && pool[p3].id == pool[p2].hireId) {
              if (tempp.seduced) {
                addstr("<Refuses Promotion>");
              } else if (pool[p3].subordinatesLeft == 0 && !tempp.brainwashed) {
                addstr("<Can't Lead More>");
              } else {
                printname(pool[p3]);
              }
              break;
            }
          }

          break;
        }
      }
      if (p2 == pool.length) addstr("<LCS Leader>");

      move(y++, 4 + level[p]);
      printname(temppool[p]);
    }

    move(21, 0);
    addstrc(lightGray, "Recruited/");
    addstrc(purple, "Seduced");
    addstrc(lightGray, "/");
    addstrc(yellow, "Enlightened");
    addstrc(yellow, "   [");
    addstrc(lightGray, "Arrested");
    addstrc(yellow, "]");
    addstrc(red, " [");
    addstrc(lightGray, "In Jail");
    addstrc(red, "]");
    addstrc(darkGray, " [");
    addstrc(lightGray, "In Hiding");
    addstrc(darkGray, "]");
    addstrc(blue, " [");
    addstrc(lightGray, "Sleeper");
    addstrc(blue, "]");
    setColor(lightGray);
    move(22, 0);
    addstr(
        "Press a letter to promote a Liberal. You cannot promote Liberals in hiding.");
    move(23, 0);
    addstr(
        "Enlightened Liberals follow anyone. Seduced Liberals follow only their lover.");
    if (temppool.length > pageLength) {
      move(24, 0);
      addstr(pageStr);
    }

    int c = await getKey();

    //PAGE UP
    if ((isPageUp(c) || c == Key.upArrow || c == Key.leftArrow) && page > 0) {
      page--;
    }
    //PAGE DOWN
    if ((isPageDown(c) || c == Key.downArrow || c == Key.rightArrow) &&
        (page + 1) * pageLength < temppool.length) {
      page++;
    }

    if (c >= Key.a && c <= Key.a + pageLength) {
      int p = page * pageLength + c - Key.a;
      Creature tempp = temppool[p];
      // can't promote liberals in hiding or seduced
      if (p < temppool.length && tempp.hidingDaysLeft == 0 && !tempp.seduced) {
        for (int p2 = 0; p2 < pool.length; p2++) {
          if (pool[p2].alive && pool[p2].id == tempp.hireId) {
            addstr(pool[p2].name);

            for (int p3 = 0; p3 < pool.length; p3++) {
              // Can't promote if new boss can't accept more subordinates
              if (pool[p3].alive &&
                  pool[p3].id == pool[p2].hireId &&
                  (tempp.brainwashed || pool[p3].subordinatesLeft > 0)) {
                tempp.hireId = pool[p2].hireId;
                sortbyhire(temppool, level);
                break;
              }
            }
            break;
          }
        }
      }
    }

    if (isBackKey(c)) break;
  }
}

void sortbyhire(List<Creature> temppool, List<int> level) {
  List<Creature> newpool = [];
  level.clear();

  for (int i = temppool.length - 1; i >= 0; i--) {
    if (temppool[i].hireId == null) {
      newpool.insert(0, temppool[i]);
      level.insert(0, 0);
      temppool.removeAt(i);
    }
  }

  bool changed;
  do {
    changed = false;

    for (int i = 0; i < newpool.length; i++) {
      for (int j = temppool.length - 1; j >= 0; j--) {
        if (temppool[j].hireId == newpool[i].id) {
          newpool.insert(i + 1, temppool[j]);
          level.insert(i + 1, level[i] + 1);
          temppool.removeAt(j);
          changed = true;
        }
      }
    }
  } while (changed);

  temppool.clear();
  for (int p = 0; p < newpool.length; p++) {
    temppool.add(newpool[p]);
  }
}
