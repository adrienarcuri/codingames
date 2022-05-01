import sys
import math

# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

# Constants
BASE_VISIBILITY = 6000 + 1100
HERO_VISIBILITY = 2200
MIN_MANA = 10

MAP_ZONE = ((0, 0), (17630, 9000))
MAP_ZONE_TO_EXPLORE = [
    (BASE_VISIBILITY, BASE_VISIBILITY),
    (BASE_VISIBILITY, 0),
    (0, BASE_VISIBILITY),
]

# pi/2
cosPI2 = math.sqrt(2) / 2
sinPI2 = cosPI2
# pi/8
cosPI8 = math.sqrt(2 + math.sqrt(2)) / 2
sinPI8 = math.sqrt(2 - math.sqrt(2)) / 2


# base_x: The corner of the map representing your base
BASE_X, BASE_Y = [int(i) for i in input().split()]
ENNEMY_BASE_X, ENNEMY_BASE_Y = [MAP_ZONE[1][0] - BASE_X, MAP_ZONE[1][1] - BASE_Y]
heroes_per_player = int(input())  # Always 3

if BASE_X == 0:
    MAP_ZONE_TO_EXPLORE = [
        (int(BASE_VISIBILITY * cosPI2), int(BASE_VISIBILITY * sinPI2)),
        (int(cosPI8 * BASE_VISIBILITY), int(sinPI8 * BASE_VISIBILITY)),
        (int(sinPI8 * BASE_VISIBILITY), int(cosPI8 * BASE_VISIBILITY)),
    ]
else:
    MAP_ZONE_TO_EXPLORE = [
        (
            BASE_X - int(BASE_VISIBILITY * cosPI2),
            BASE_Y - int(BASE_VISIBILITY * sinPI2),
        ),
        (
            BASE_X - int(cosPI8 * BASE_VISIBILITY),
            BASE_Y - int(sinPI8 * BASE_VISIBILITY),
        ),
        (
            BASE_X - int(sinPI8 * BASE_VISIBILITY),
            BASE_Y - int(cosPI8 * BASE_VISIBILITY),
        ),
    ]


def debug(msg):
    print(msg, file=sys.stderr, flush=True)


def distance_to_my_base(x, y):
    return math.dist([BASE_X, BASE_Y], [x, y])


class PlayerInfo:
    def __init__(self, playerid, mana, health):
        self.playerid = (playerid,)
        self.mana = mana
        self.health = health
        self.base_x = BASE_X
        self.base_y = BASE_Y

    def __str__(self):
        return f"playerid:{self.playerid}, mana:{self.mana},health:{self.health}"


class Entity:
    def __init__(self, id, entity_type, x, y):
        self.id = id
        self.entity_type = entity_type
        self.x = x
        self.y = y

    def distanceTo(self, e):
        """Return distance to entity e"""
        return math.dist([self.x, self.y], [e.x, e.y])


class Hero(Entity):
    def __init__(self, id, entity_type, x, y):
        super().__init__(id, entity_type, x, y)


class Monster(Entity):
    def __init__(self, id, entity_type, x, y, health, vx, vy, near_base, threat_for):
        self.health = health
        self.vx = vx
        self.vy = vy
        self.near_base = near_base
        self.threat_for = threat_for
        super().__init__(id, entity_type, x, y)

        self.threat = self._threat()

    def _threat(self):
        return 1 / (1 + distance_to_my_base(self.x, self.y))

    def __str__(self):
        return f"id:{self.id},theat:{self.threat}, entity_type:{self.entity_type}, x:{x}, y:{y}"


class Commands:
    @staticmethod
    def _p(cmd, msg):
        print(f"{cmd} {msg}")

    @staticmethod
    def wait():
        cmd = "WAIT"
        msg = "Attend ! 🕗"
        Commands._p(cmd, msg)

    @staticmethod
    def move(x, y):
        cmd = f"MOVE {x} {y}"
        msg = "Bouge ! 🏃‍♀️"
        Commands._p(cmd, msg)

    @staticmethod
    def spell(x, y):
        cmd = f"SPELL WIND  {x} {y}"
        msg = "Et le vent souflera 💨"
        Commands._p(cmd, msg)

    @staticmethod
    def spell_ennemy_base():
        Commands.spell(ENNEMY_BASE_X, ENNEMY_BASE_Y)

    @staticmethod
    def shield(s):
        cmd = f"SPELL SHIELD {s}"
        msg = "Bouclier 🛡"
        Commands._p(cmd, msg)


# game loop
while True:
    monsters = []
    myHeroes = []
    ennemyHeroes = []
    playerInfos = []
    for i in range(2):
        # health: Each player's base health
        # mana: Ignore in the first league; Spend ten mana to cast a spell
        health, mana = [int(j) for j in input().split()]
        playerInfos.append(PlayerInfo(playerid=i, mana=mana, health=health))
    entity_count = int(input())  # Amount of heros and monsters you can see
    for i in range(entity_count):
        # _id: Unique identifier
        # _type: 0=monster, 1=your hero, 2=opponent hero
        # x: Position of this entity
        # shield_life: Ignore for this league; Count down until shield spell fades
        # is_controlled: Ignore for this league; Equals 1 when this entity is under a control spell
        # health: Remaining health of this monster
        # vx: Trajectory of this monster
        # near_base: 0=monster with no target yet, 1=monster targeting a base
        # threat_for: Given this monster's trajectory, is it a threat to 1=your base, 2=your opponent's base, 0=neither
        (
            _id,
            _type,
            x,
            y,
            shield_life,
            is_controlled,
            health,
            vx,
            vy,
            near_base,
            threat_for,
        ) = [int(j) for j in input().split()]

        # PARSING ENTITY
        # If Monster
        if _type == 0:
            monsters.append(
                Monster(
                    id=_id,
                    entity_type=_type,
                    x=x,
                    y=y,
                    health=health,
                    vx=vx,
                    vy=vy,
                    near_base=near_base,
                    threat_for=threat_for,
                )
            )
        # If my Hero
        elif _type == 1:
            myHeroes.append(Hero(id=_id, entity_type=_type, x=x, y=y))
        # If ennemy Hero
        elif _type == 2:
            pass
        else:
            assert False

    for i in range(heroes_per_player):
        myHero = myHeroes[i]

        # Garder uniquement les monstres qui sont une menace
        monsters = [monster for monster in monsters if monster.threat_for == 1]
        # S'il y a des monstres menaçants
        if monsters:
            monsters.sort(key=lambda x: x.threat, reverse=True)

            monster = monsters[0]
            # Si j'ai assez de mana et que le    est à bonne distance du héro
            if playerInfos[0].mana >= MIN_MANA and myHero.distanceTo(monster) < 1280:
                Commands.spell_ennemy_base()
                playerInfos[0].mana -= 10
            else:
                Commands.move(monster.x, monster.y)
        # S'il n'y a pas de monstre
        elif not monsters:
            # Explore
            Commands.move(MAP_ZONE_TO_EXPLORE[i][0], MAP_ZONE_TO_EXPLORE[i][1])

        else:
            Commands.wait()
