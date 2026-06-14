Class AI_RFTrooper_Storm : AI_Monster
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
			
			AI_Monster.AttackRange 1000;
			AI_Monster.CanIDodge false;
			AI_Monster.CanIJump false;
			AI_Monster.MaxLeapHeightDif 60;
			AI_Monster.MaxLeapDistance 200;
			
			//AI_Monster.CustomStepSound "Badass/Boot";
			
			SeeSound "GNZombie/see";
			PainSound "GNZombie/pain";
			DeathSound "GNZombie/death";
			ActiveSound "GNZombie/active";
			
			DropItem "ARifle_Magazine", 32, 2;
			DropItem "HeavyPistolAmmo", 96;
			DropItem "LightPistolAmmo", 128;
			
			Decal "BlazeChip";
			Obituary "%o was taken down by a Possessed Assault Trooper.";
			Tag "\cdPossessed Assault Trooper";
			PainChance "PlasmaFire", 255;
		}
		
		int HowManyGrenadesHaveIThrown;
		
		void FireProjBullets()
		{
			A_Light(2);
			A_PlaySound("Weapons/StormFireN",CHAN_Auto);
			A_PlaySound("Weapons/StormFireAdd",CHAN_AUTO);
			A_PlaySound("Weapons/StormPunch",CHAN_AUTO);
			A_SpawnProjectile("apscasing_spawner",30,15,0,5,0);
			A_SpawnProjectile("p_autopistol_tracer", 43, 2.5, frandom(-8,8), CMF_OFFSETPITCH , frandom(-8,8));
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
		}
		
		override void Tick()
		{
			Super.Tick();
		}
		
		States
		{
		
		Spawn:
			RFR4 A 1;
			TNT1 A 0;
		Stand:
			RFR4 AAAA 5
			{
				A_LookEx();
				A_SetScale(scale.X,Scale.Y+0.01);
			}
			RFR4 AAAA 5
			{
				A_LookEx();
				A_SetScale(scale.X,Scale.Y-0.01);
			}
			TNT1 A 0 A_Jump(96, "Wander");
			Loop;
		Wander:
			RFR4 AAAABBBB 1 AI_SmartChase();
			RFR4 CCCCDDDD 1 AI_SmartChase();
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
			RFR4 AAAABBBB 1 AI_SmartChase();
			TNT1 A 0 A_Fallback();
			RFR4 CCCCDDDD 1 AI_SmartChase();
			TNT1 A 0 A_Fallback();
			Loop;
		FallBack:
			TNT1 A 0 A_Jump(255, "Fallback1", "Roll", "See");
		FallBack1:
			RFR4 D 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR4 C 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR4 B 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR4 A 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR4 D 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR4 C 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR4 B 3 {
				A_FaceTarget(10);
				A_Recoil(2);
				return A_Jump(64,"Missile");
			}
			RFR4 A 3 {
				A_FaceTarget(10);
				A_Recoil(2);
			}
			Goto Missile;
		
		////////////////
		//Attack Logic// 
		////////////////
		Melee:
			RFR4 A 1 A_CheckLOF(1);
			Goto See;
			RFR4 A 1 A_FaceTarget(45, 45, 0, 0, FAF_MIDDLE);
			RFR1 E random(10,20);
			RFR1 G 6
			{
				//Melee attack
				A_StartSound("Fists/Swing");
				A_CustomMeleeAttack(random(10, 30), "Fists/HitFlesh");
			}
			RFR4 E 6;
			Goto See;
		Missile:
			TNT1 A 0 A_JumpIf(AttackDelay > 3, "See");
			RFR4 E 1 A_CheckLOFRanged("AttackHandler", "Roll");
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
				
				return A_Jump(256, "Attack1");
			}
		
		Attack1:
			TNT1 A 0
			{
				if(AmmoInMag <= 0)
				{
					A_Jump(256,"Reload");
				}
			}
			RFR4 E 1 A_FaceTarget();
			RFR4 F 1 BRIGHT FireProjBullets;
			RFR4 E 2;
			RFR4 A 0 A_Jump(240,"Attack1");
			Goto See;
			
		Grenade:
			TNT1 A 0 A_JumpIfCloser(500, 1);
			Goto Attack1;
			TNT1 A 0 A_JumpIfCloser(90, "Attack1");
		ThrowGrenade:
			TNT1 A 0; //Grenade sound
			RFR4 E 6
			{
				A_ActiveSound();
				A_FaceTarget(90,45);
			}
			RFR4 E 6;
			RFR4 E 6
			{
				A_FaceTarget(90,45);
				FireProjGren();
			}
			RFR4 E 6;
			Goto See;
		
		NoAmmo:
			RFR4 E 1 A_FaceTarget();
			RFR4 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR4 E 1 A_FaceTarget();
			RFR4 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR4 E 1 A_FaceTarget();
			RFR4 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR4 E 1 A_FaceTarget();
			RFR4 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR4 E 1 A_FaceTarget();
			RFR4 E 4 A_PlaySound("Weapons/TormentorCycle");
			RFR4 E 10;
			TNT1 A 0 A_Jump(256, "See", "Reload");
			Goto See;
		Reload:
			RFR4 A 6;
			RFR4 E 9 A_PlaySound("Weapons/StormMagOut");
			RFR4 E 16;
			RFR4 E 11 A_PlaySound("Weapons/DevMagOut");
			RFR4 E 6 A_PlaySound("Weapons/StormMagIn");
			RFR4 E 8 A_PlaySound("Weapons/StormMagLock");
			TNT1 A 0
			{
				AmmoInMag = 32;
			}
			RFR4 A 4;
			Goto See;

		////////////////
		//Pain Logic// 
		////////////////
		Pain:
			TNT1 A 0 A_JumpIf(kickeddown, "KickedPain");
			RFR4 G 6 A_Pain();
			Goto See;
		
		Raise:
			RFR4 LKJIHG 3;
			Goto Spawn;
		
		
		////////////////////
		//Generic By Actor//
		////////////////////
		
		Roll:
			TNT1 A 0 A_Jump(256, "SHR", "SHL", "See");
		SHR:
			RFR4 A 3 A_FaceTarget;
			RFR4 E 3
			{
				A_FaceTarget();
				A_ChangeVelocity(frandom(5,-5), -8, 0, CVF_RELATIVE);
			}
			RFR4 E 24;
		SHRL:
			RFR4 E 1 A_CheckFloor("SHRE");
			RFR4 E 1;
			Loop;
		SHRE:
			RFR4 E 1 A_FaceTarget;
			TNT1 A 0 A_Stop();
			TNT1 A 0 A_Jump(256, "See", "Missile");
			Goto See;
		SHL:
			RFR4 A 3 A_FaceTarget;
			RFR4 E 3
			{
				A_FaceTarget();
				A_ChangeVelocity(frandom(5,-5), 8, 0, CVF_RELATIVE);
			}
			RFR4 E 24;
		SHLL:
			RFR4 E 1 A_CheckFloor("SHLE");
			RFR4 E 1 A_CheckCeiling("SHLE");
			Loop;
		SHLE:
			RFR4 E 1 A_FaceTarget;
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
			RFR4 HIJK 3;
			RFR4 L -1;
			Stop;
		XDeath:
			TNT1 A 0
			{
				A_XScream();
				A_NoBlocking();
			}
			RFR4 MNOP 3;
			RFR4 Q -1;
			Stop;
	}
}