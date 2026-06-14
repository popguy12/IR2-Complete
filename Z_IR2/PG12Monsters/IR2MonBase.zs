class AI_Monster : Actor
{
	int EnemyLastSighted;
	bool Wandering;
	bool willBeLooking;
	int heardOpponent;
	
	bool kickeddown;
	
	int ActiveSoundPlayChance;
	int MissileChance;
	int FallbackChance;
	
	int AttackDelay;
	
	int enemyRange;
	Property AttackRange : enemyRange;
	//the enemies attack range, in case you wanted some enemies to be CQC mainly, or snipe
	
	bool canJump;
	property CanIJump : canJump;
	bool candodge;
	property CanIDodge : canDodge;
	//bools controlling whether an enemy can Dodge if the player is looking at them
	//or if they can use ZSDukes leaping system
	
	bool canReload;
	property CanIReload : canReload;
	
	string soundBase;
	Property SoundCategory : soundBase;
	//used for A_SmartPain
	
	int maxLeapCheck;
	Property MaxLeapHeightDif : maxLeapCheck;
	double maxLeapDis;
	Property MaxLeapDistance : maxLeapDis;
	//this will be used for enemies that can leap to chase the player, think of it as a max jump height and jump radius
	int leapCounter; //gotta use a counter for the IR2 enemies, for some reason they broke somethin with the leap code
	
	double Mana; //For Demons, or anything else that itd make sense on.
	
	int AmmoInMag;
	int Timer;
	
	string customFootstep;
	property CustomStepSound:customFootstep;
	
	//The main custom A_Chase function
	
	void AI_SmartChase()
	{
		if(!target)	//looking cycle
		{
			if(Wandering)
			{
				A_Wander();
				A_LookEx();
				return;
			}
			else
				Wandering = true;
		}
		else		//chasing cycle, only enter if target != null
		{
			if(isFriend(target))
			{
				A_ClearTarget();
				return;
			}

			if(target.health < 0)
			{
				Wandering = true;
				A_ClearTarget();
				return;
			}

			A_Fallback();
			
			if(self.canJump == true)
			{
				if(TryLeap(ResolveState("Leap"), JF_ALL))
				{
					return;
				}
			}
			
			if(waterlevel >= 1 && Target.Pos.Z > (self.Pos.Z + 10))
			{
				A_FaceTarget(30);
				A_Recoil(-3);
				ThrustThingZ(0, 5, 0, 1);
			}

			if (CheckSight(target) == true && CheckIfCloser(target, 3000))
			{
				double dist = Distance3D(target);

				MissileChance = (random(1,300));
				ActiveSoundPlayChance = (random(1,300));

				//check if sight of player or close enough to "hear" player for memory
				if (CheckSight(target) || CheckIfCloser(target, 500))
				{
					EnemyLastSighted = Level.MapTime;
					Wandering = false;
				}

				if(candodge)
				{
					//dodging system check
					LookExParams look;
					look.FOV = 2;
					int chance = (random(1,300));
					
					if(target.IsVisible(self, false, look) && chance <= 10 && dist <= 1500 && resolvestate("Roll"))
					{
						A_FaceTarget();
						SetStateLabel("Roll");
					}
					
				}
				A_Chase();

			}
			else if (CheckSight(target) == false && abs(Level.MapTime - EnemyLastSighted) < 360)
			{
				ActiveSoundPlayChance = (random(1,300));
				//because 1 tic A_Chase calls spams this lol
				if((ActiveSoundPlayChance > 5 ))
				{
					A_Chase("_a_chase_default", "_a_chase_default", CHF_NOPLAYACTIVE);
				}
				else
				{
					A_Chase();
				}

				int chanceR = (random(1,10));
			
				// Do our Reload checks while the player is out of sight.
				if(bFRIGHTENED && canReload && chanceR <= 5 && ResolveState("Reload"))
				{
					SetStateLabel("Reload");
					return;
				}
			}
			else
			{
				Wandering = true;
				A_ClearTarget();
			}

			
		}
		
	}
	
	//Extra functions for firing checks and pain checks
	
	void A_CheckLOFRanged(statelabel jumpstate, statelabel dodgestate, statelabel seeContinuestate = "SeeContinue")
	{
		if(!target)
			return;
		double dist = Distance3D(target);
		let aimActor = AimTarget();
		
		if(dist > self.enemyRange) // Too far away.
		{
			//Console.PrintF("Not Closer");
			SetStateLabel(seeContinuestate);
		}
		else if(CheckLOF() && dist <= self.enemyRange) /*(aimActor is "PlayerPawn" && dist <= self.enemyRange)*/ // Can aim at the player.
		{
			//Console.PrintF("Closer and LOF");
			SetStateLabel(jumpstate);
		}
		else // Aim obstructed
		{
			//Console.PrintF("Else Failed, Dodging");
			if(self.candodge == true)
			{				
				SetStateLabel(dodgestate);
			}
			else
			{
				SetStateLabel(seeContinuestate);
			}
		}
	}
	
	void A_Fallback(statelabel fallbackstate = "Fallback")
	{
		FallbackChance = (random(1,300));
		
		if (CheckIfCloser(target, 150) && !CheckIfCloser(target, 100) && CheckSight(target) && (FallbackChance < 25))
		{
			SetStateLabel(fallbackstate);
		}
	}
	
	int footstepWait;
	//Tick and PostBeginPlay stuff
	override void Tick()
	{
		Super.Tick();
		AttackDelay--;
		if(AttackDelay < 0)
		{
			AttackDelay = 0;
		}
		
		//[Pop] This way enemies can have custom footstep timing logic
		FootstepLogic();
	}
	
	virtual void FootstepLogic()
	{
		//if(vel.xy.length() > 1)	//monster do not get vel when walking
		//	PlayFootsteps();
		//this would be more accurate if done in the states, but its easier to do it from here
		if(footstepWait-- <= 0 && pos.z <= floorz + 1 && levellocals.Vec2Diff(prev.xy,pos.xy).length() > 3)
		{
			PlayFootsteps();
			footstepWait = 9;
		}
	}
	
	virtual void PlayFootsteps()
	{
		if(health < 1)
			return;
		if(customFootstep)
			A_Startsound(customFootstep,CHAN_AUTO,volume:1.0,attenuation:(1200/700));
	}
	
	//Precise monster jumping from ZSDuke
	
	enum EJumpFlags
    {
        JF_FORWARD = (1<<0),
        JF_UP = (1<<1),
        
        JF_ALL = JF_FORWARD|JF_UP
    }
	
	int oldLeap;
    double leapDistance;

    void A_Leap()
    {
        // if grounded, go to see.
        if (CheckOnGround())
        {
            if (!oldLeap)
            {
                A_FaceTarget();
                double vertical = 12;
                if (target.pos.z-pos.z > 64 && ceilingz-pos.z > 128) vertical = 18;
                double horizontalMult = leapDistance / 1000;
                double horizontal = 1;
                for (int i = 0; i < 4; i++) horizontal *= horizontalMult; // pow is not defined
                vector3 newdir = (cos(angle)*horizontal, sin(angle)*horizontal, vertical);
                vel += newdir;
                oldLeap = frame;
            }
            else
            {
				A_Stop();
                SetState(ResolveState("See"));
                return;
            }
        }
        else if (vel.z > 0)
        {
            vector3 newdir = (cos(angle)*2, sin(angle)*2, 0);
            vel += newdir;
            //frame = oldLeap+1;
        }
        else if (vel.z < 0)
        {
            //frame = oldLeap+2;
        }
    }
	//as far as i can tell, these two frame lines control the sprite frame used for the animation
	//so make sure that the 3 frames for this are one after another, or just comment them both out if you only have 1 frame
    
    virtual double GetJumpDistance()
    {
        double dst = 480;//self.maxLeapDis; //default is 480
        if (ceilingz-pos.z > 128) dst *= 2;
        return dst;
    }
	
	double GetGroundHeight()
    {
        double _floorz = GetZAt();
        bool ok; Actor pOnmobj;
        [ok, pOnmobj] = TestMobjZ(true);
        if (!pOnmobj) return _floorz;
        double _actorz = pOnmobj.pos.z+pOnmobj.height;
        return max(_floorz, _actorz);
    }
	
	bool CheckOnGround()
    {
        return (abs(GetGroundHeight()-pos.z) < 1);
    }
	
    bool CheckPitBeforeTarget()
    {
        if (!CheckSight(target)) return false;
        
        int step = int(radius/2);
        vector3 checkdirection = (target.pos-pos).Unit()*step;
        int steps = min(Distance2D(target), GetJumpDistance())/step;
        double curz = pos.z;
        SetXYZ((pos.x, pos.y, pos.z+64));
        for (int i = 0; i < steps; i++)
        {
            double zat = GetZAt(pos.x+checkdirection.x*i, pos.y+checkdirection.y*i, 0, GZF_ABSOLUTEPOS|GZF_ABSOLUTEANG);
            //A_LogFloat(zat);
            if (curz-zat > MaxStepHeight*2 || zat-curz > MaxStepHeight)
            {
                SetXYZ((pos.x, pos.y, curz));
                return true;
            }
        }
        
        SetXYZ((pos.x, pos.y, curz));
        return false;
    }
    
    bool TryLeap(state leapstate, EJumpFlags flags)
    {
        if (!target) return false;
        //
        if (CheckOnGround() && // if we are standing
            !random(0, 64) && // and we don't do this all the time
            (((flags & JF_UP) && (abs(target.pos.z-pos.z) > Default.MaxStepHeight)) || //&& abs(target.pos.z-pos.z) < self.maxLeapCheck)) || // and target has more height difference than maxstepheight
             ((flags & JF_FORWARD) && CheckPitBeforeTarget())) && // and there's a deep pit in front of us
            Distance2D(target) < GetJumpDistance()) // and target is within max jump radius
        {
			A_Stop();
            oldLeap = 0;
            leapDistance = Distance2D(target);
            SetState(ResolveState("Leap"));
            return true;
        }
        
        return false;
    }
	
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		heardOpponent = 0;
		AttackDelay = 25;
	}
	
	default
	{
		Monster;
		+FLOORCLIP;
		+SLIDESONWALLS;
		+DOHARMSPECIES;
		+HARMFRIENDS;
		+ROLLSPRITE;
		+ROLLCENTER;
		+FORCEPAIN;
		Species "AIMonster";
		MaxStepHeight 24;
		MaxDropOffHeight 32;
		
		AI_Monster.CanIDodge false;
		AI_Monster.CanIReload true;
	}
}