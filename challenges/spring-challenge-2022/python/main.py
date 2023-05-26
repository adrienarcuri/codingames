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

    def distance_base(self):
        return distance_to_my_base(self.x, self.y)

    def __str__(self):
        return f"id:{self.id}, entity_type:{self.entity_type}, x:{self.x}, y:{self.y}"


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
        threat_score = 0
        # Menace pour personne
        if threat_for == 0:
            threat_score = 0
        # Menace pour moi
        elif threat_for == 1:
            threat_score = 0
        # Menace pour l'ennemi
        elif threat_for == 2:
            threat_score = -1
        return threat_score + 1 / (1 + distance_to_my_base(self.x, self.y))

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

    @staticmethod
    def control(entityId, x, y):
        cmd = f"CONTROL {entityId} {x} {y}"
        msg = "Control ✇"
        Commands._p(cmd, msg)

    @staticmethod
    def control_ennemy_base(entityId):
        debug
        Commands.control(entityId, ENNEMY_BASE_X, ENNEMY_BASE_Y)


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
            h = Hero(_id, _type, x, y)
            myHeroes.append(h)
            debug(h)
        # If ennemy Hero
        elif _type == 2:
            pass
        else:
            assert False

    # On ne garde pas les monstres qui sont une menace pour la base ennemie
    monsters = [monster for monster in monsters if monster.threat_for != 2]

    # Si aucun monstre visible
    if not monsters:
        for j in range(heroes_per_player):
            debug(j)
            debug(len(myHeroes))
            myHero = myHeroes[j]
            # Explorer
            Commands.move(MAP_ZONE_TO_EXPLORE[j][0], MAP_ZONE_TO_EXPLORE[j][1])
    # Sinon
    elif monsters:
        # Classement des monstres par ordre de menace décroissante
        monsters.sort(key=lambda x: x.threat, reverse=False)
        # Pour chaque monstre
        couples = {0: -1, 1: -1, 2: -1}
        for monster in monsters:
            # Déterminer le hero le plus proche
            heroes = myHeroes.copy()
            for h in heroes:
                
                d_best = 10000000000
                d = monster.distanceTo(h)
                if d < d_best:
                    my_nearest_Hero = h
                    d_best = d
            couples[my_nearest_Hero.id] = monster
            heroes.remove(my_nearest_Hero)

        for i in range(heroes_per_player):
            if couples[i] != -1:
                monster = couples[i]
                # Si j'ai assez de mana
                if playerInfos[0].mana >= MIN_MANA:
                    # Si le monstre est à porté de ma base
                    if monster.distance_base() < 5000:
                        # Si monstre à porté pour sort wind.
                        if monster.distanceTso(myHero) < 1280:
                            # Sort Vent vers la base ennemie
                            Commands.spell_ennemy_base()
                            playerInfos[0].mana -= 10
                        # Si monstre à porté pour sort control:
                        elif monster.distanceTo(myHero) < 2200:
                            # Sort Control vers la base ennemie
                            Commands.control_ennemy_base(monster.id)
                            playerInfos[0].mana -= 10
                        # Sinon
                        else:
                            Commands.move(monster.x, monster.y)
                    # Sinon
                    else:
                        # Sort Control vers la base ennemie
                        Commands.control_ennemy_base(monster.id)
                        playerInfos[0].mana -= 10

                # Sinon si je n'ai pas assez de mana
                else:
                    # Avance vers le monstre
                    Commands.move(monster.x, monster.y)
            else:
                Commands.wait()

        else:
            Commands.wait()
