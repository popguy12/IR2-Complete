Class AI_RFTrooper_Omen : AI_Monster
{
		Default
		{
			Radius 16;
			Height 56;
			Speed 4;
			FastSpeed 6;
			Mass 100;
			Health 100;
			GibHealth -400;
			PainChance 200;
			Scale 1; //Make sure to adjust the values in the See state to match these
			BloodColor "7F0000";
			
			AI_Monster.AttackRange 2000;
			AI_Monster.CanIDodge false;
			AI_Monster.CanIJump false;
			AI_Monster.MaxLeapHeightDif 60;
			AI_Monster.MaxLeapDistance 200;
			
			//AI_Monster.CustomStepSound "Badass/Boot";
			
			SeeSound "GNZombie/see";
			PainSound "GNZombie/pain";
			DeathSound "GNZombie/death";
			ActiveSound "GNZombie/active";
			
			Dropitem "Omen", 16,1;
			DropItem "ARifle_Magazine", 32,2;
			DropItem "HeavyPistolAmmo", 96;
			DropItem "LightPistolAmmo", 128;
			
			Decal "BlazeChip";
			Obituary "%o was taken down by a Possessed Assault Trooper.";
			Tag "\cdPossessed Assault Trooper";
			PainChance "PlasmaFire", 255;
		}
		
		int HowManyGrenadesHaveIThrown;
		
		bool AltAmmoLoaded;
		
		void FireProjBullets(bool AltAmmo)
		{
			A_Light(2);
			if(!AltAmmo)
			{
				A_PlaySound("Weapons/OmenFire",CHAN_Auto);
				A_SpawnProjectile("ARifleCasing_Spawner",30,15,0,5,0);
				A_SpawnProjectile("p_arifle_tracer", 43, 2.5, frandom(-8,8), CMF_OFFSETPITCH , frandom(-8,8));
			}
			else
			{
				A_PlaySound("Weapons/OmenFire",CHAN_Auto);
				A_SpawnProjectile("ARifleCasing_Spawner_X",30,15,0,5,0);
				A_SpawnProjectile("p_hrifle_tracer", 43, 2.5, frandom(-8,8), CMF_OFFSETPITCH , frandom(-8,8));
			}
			AmmoInMag--;
		}
		
		void FireProjGren()
		{
			A_ThrowGrenade("Grenade", 0, 10, 4);
			HowManyGrenadesHaveIThrown++;
		}
		
		override void PostBeginPlay()
		{
			Super.PostBeginPlay(); // call the super function for virtual functions so we don't break shit if GZdoom update.
		}
		
		override void BeginPlay()
		{
			super.BeginPlay();
			AmmoInMag = random(20,40); //Storm
			AltAmmoLoaded = false;
		}
		
		override void Tick()
		{
			Super.Tick();
		}
		
		States
		{
		
		Spawn:
			RFR1 A 1;
			TNT1 A 0;
		Stand:
			RFR1 AAAA 5
			{
				A_LookEx();
				A_SetScale(scale.X,Scale.Y+0.01);
			}
			RFR1 AAAA 5
			{
				A_LookEx();
				A_SetScale(scale.X,Scale.Y-0.01);
			}
			TNT1 A 0 A_Jump(96, "Wander");
			Loop;
		Wander:
			RFR1 AAAABBBB 1 AI_SmartChase();
			RFR1 CCCCDDDD 1 AI_SmartChase();
			TNT1 A 0 A_Jump(32, "Stand");
			Loop;
		See:
			TNT1 A 0
			{
				A_SetScale(1,1);
				EnemyLastSighted = Level.MapTime;
				if(AmmoInMag < 5)
				{
					bFRIGHTENED = true;
				}
				else
				{
					bFRIGHTENED = false;
				}
			}
		SeeContinue:
			RFR1 AAAABBBB 1 AI_SmartChase();
			TNT1 A 0 A_Fallback();
			RFR1 CCCCDDDD 1 AI_SmartChase();
			TNT1 A 0 A_Fallback();
			Loop;
		FallBack:
			TNT1 A 0 A_Jump(255, "Fallback1", "Roll", "See");
		FallBack1:
			RFR1 D 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR1 C 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR1 B 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR1 A 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR1 D 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR1 C 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR1 B 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR1 A 3 {
				A_FaceTarget(10);
				A_Recoil(2);
			}
			Goto Missile;
		
		////////////////
		//Attack Logic// 
		////////////////
		Melee:
			RFR1 A 1 A_CheckLOF(1);
			Goto See;
			RFR1 A 1 A_FaceTarget(45, 45, 0, 0, FAF_MIDDLE);
			RFR1 E random(10,20);
			RFR1 G 6
			{
				//Melee attack
				A_StartSound("Fists/Swing");
				A_CustomMeleeAttack(random(10, 30), "Fists/HitFlesh");
			}
			RFR1 E 6;
			Goto See;
		Missile:
			TNT1 A 0 A_JumpIf(AttackDelay > 3, "See");
			RFR1 E 1 A_CheckLOFRanged("AttackHandler", "Roll");
			Goto See;
		AttackHandler:
			TNT1 A 0
			{
				int chance = (random(1,256));
				
				/*if((chance > 232) && (HowManyGrenadesHaveIThrown < 4))
				{
					return A_Jump(256, "Grenade");
				}*/
				
				if(AmmoInMag <= 0)
				{
					return A_Jump(256,"NoAmmo");
				}
				
				AttackDelay = AttackDelay + 35;
				
				return A_Jump(256, "Attack1", "Attack2");
			}
		
		Attack1:
			TNT1 A 0
			{
				if(AmmoInMag <= 3)
				{
					A_Jump(256,"Reload");
				}
			}
			RFR1 E 1 A_FaceTarget();
			RFR1 F 1 BRIGHT FireProjBullets(AltAmmoLoaded);
			RFR1 E 1;
			RFR1 F 1 BRIGHT FireProjBullets(AltAmmoLoaded);
			RFR1 E 1;
			RFR1 F 1 BRIGHT FireProjBullets(AltAmmoLoaded);
			RFR1 E 1;
			RFR1 F 1 BRIGHT FireProjBullets(AltAmmoLoaded);
			RFR1 E 1 A_SetTics(random(8,16));
			RFR1 A 0 A_Jump(128,"Attack1");
			Goto See;
		Attack2:
			TNT1 A 0
			{
				if(AmmoInMag <= 0)
				{
					A_Jump(256,"Reload");
				}
			}
			RFR1 E 1 A_FaceTarget();
			RFR1 F 1 BRIGHT FireProjBullets(AltAmmoLoaded);
			RFR1 E 3;
			RFR1 A 0 A_Jump(240,"Attack2");
			Goto See;
			
		Grenade:
			TNT1 A 0 A_JumpIfCloser(500, 1);
			Goto Attack1;
			TNT1 A 0 A_JumpIfCloser(90, "Attack1");
		ThrowGrenade:
			TNT1 A 0; //Grenade sound
			RFR1 E 6
			{
				A_ActiveSound();
				A_FaceTarget(90,45);
			}
			RFR1 E 6;
			RFR1 E 6
			{
				A_FaceTarget(90,45);
				FireProjGren();
			}
			RFR1 E 6;
			Goto See;
		
		NoAmmo:
			RFR1 E 1 A_FaceTarget();
			RFR1 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR1 E 1 A_FaceTarget();
			RFR1 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR1 E 1 A_FaceTarget();
			RFR1 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR1 E 1 A_FaceTarget();
			RFR1 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR1 E 1 A_FaceTarget();
			RFR1 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR1 E 10;
			TNT1 A 0 A_Jump(256, "See", "Reload");
			Goto See;
		Reload:
			RFR1 A 6;
			RFR1 E 1 A_PlaySound("ArchangelK61/MagHit");
			RFR1 E 1 A_PlaySound("ArchangelK61/MagOut");
			RFR1 E 6;
			//Spawn empty mag
			RFR1 E 25;
			RFR1 E 16 A_PlaySound("ArchangelK61/MagIn");
			RFR1 E 20 A_PlaySound("SK410/MagHit");
			RFR1 E 8 A_PlaySound("ArchangelK61/BoltRelease");
			TNT1 A 0
			{
				if(random(1,3))
				{
					AltAmmoLoaded = !AltAmmoLoaded;
				}
				AmmoInMag = 80;
			}
			RFR1 A 4;
			Goto See;

		////////////////
		//Pain Logic// 
		////////////////
		Pain:
			TNT1 A 0 A_JumpIf(kickeddown, "KickedPain");
			RFR1 G 6 A_Pain();
			Goto See;
		
		Raise:
			RFR1 LKJIHG 3;
			Goto Spawn;
		
		
		////////////////////
		//Generic By Actor//
		////////////////////
		
		Roll:
			TNT1 A 0 A_Jump(256, "SHR", "SHL", "See");
		SHR:
			RFR1 A 3 A_FaceTarget;
			RFR1 E 3
			{
				A_FaceTarget();
				A_ChangeVelocity(frandom(5,-5), -8, 0, CVF_RELATIVE);
			}
			RFR1 E 24;
		SHRL:
			RFR1 E 1 A_CheckFloor("SHRE");
			RFR1 E 1;
			Loop;
		SHRE:
			RFR1 E 1 A_FaceTarget;
			TNT1 A 0 A_Stop();
			TNT1 A 0 A_Jump(256, "See", "Missile");
			Goto See;
		SHL:
			RFR1 A 3 A_FaceTarget;
			RFR1 E 3
			{
				A_FaceTarget();
				A_ChangeVelocity(frandom(5,-5), 8, 0, CVF_RELATIVE);
			}
			RFR1 E 24;
		SHLL:
			RFR1 E 1 A_CheckFloor("SHLE");
			RFR1 E 1 A_CheckCeiling("SHLE");
			Loop;
		SHLE:
			RFR1 E 1 A_FaceTarget;
			TNT1 A 0 A_Stop();
			TNT1 A 0 A_Jump(256, "Roll", "See", "Missile");
			Goto See;
		

		//////////////////////////////////////////////////////////////
		//deaths
		///////////////////////////////////////////////////////////////
		Death:
			TNT1 A 0
			{
				A_Scream();
				A_NoBlocking();
			}
			RFR1 HIJK 3;
			RFR1 L -1;
			Stop;
		XDeath:
			TNT1 A 0
			{
				A_XScream();
				A_NoBlocking();
			}
			RFR1 MNOP 3;
			RFR1 Q -1;
			Stop;
	}
}