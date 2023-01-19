package;

import flixel.FlxState;
#if mobileCweb
import mobile.flixel.FlxHitbox;
import mobile.flixel.FlxVirtualPad;
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
#end

class FlxTransitionableState extends FlxState
{
	public static var defaultTransIn:TransitionData = null;
	public static var defaultTransOut:TransitionData = null;

	public static var skipNextTransIn:Bool = false;
	public static var skipNextTransOut:Bool = false;

	public var transIn:TransitionData;
	public var transOut:TransitionData;

	public var hasTransIn(get, never):Bool;
	public var hasTransOut(get, never):Bool;

	#if mobileCweb
	var hitbox:FlxHitbox;
	var virtualPad:FlxVirtualPad;
	var trackedInputsHitbox:Array<FlxActionInput> = [];
	var trackedInputsVirtualPad:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode, ?visible = true):Void
	{
		if (virtualPad != null)
			removeVirtualPad();

		virtualPad = new FlxVirtualPad(DPad, Action);
		virtualPad.visible = visible;
		add(virtualPad);

		controls.setVirtualPadUI(virtualPad, DPad, Action);
		trackedInputsVirtualPad = controls.trackedInputsUI;
		controls.trackedInputsUI = [];
	}

	public function addVirtualPadCamera(DefaultDrawTarget:Bool = true):Void
	{
		if (virtualPad != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			camControls.bgColor.alpha = 0;
			virtualPad.cameras = [camControls];
		}
	}

	public function removeVirtualPad():Void
	{
		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		if (virtualPad != null)
			remove(virtualPad);
	}

	public function addHitbox(?visible = true):Void
	{
		if (hitbox != null)
			removeHitbox();

		hitbox = new FlxHitbox();
		hitbox.visible = visible;
		add(hitbox);

		controls.setHitBox(hitbox);
		trackedInputsHitbox = controls.trackedInputsNOTES;
		controls.trackedInputsNOTES = [];
	}

	public function addHitboxCamera(DefaultDrawTarget:Bool = true):Void
	{
		if (hitbox != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			camControls.bgColor.alpha = 0;
			hitbox.cameras = [camControls];
		}
	}

	public function removeHitbox():Void
	{
		if (trackedInputsHitbox.length > 0)
			controls.removeVirtualControlsInput(trackedInputsHitbox);

		if (hitbox != null)
			remove(hitbox);
	}
	#end

	override function destroy()
	{
		#if mobileCweb
		if (trackedInputsHitbox.length > 0)
			controls.removeVirtualControlsInput(trackedInputsHitbox);

		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);
		#end

		super.destroy();

                transIn = null;
		transOut = null;
		_onExit = null;

		#if mobileCweb
		if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);

		if (hitbox != null)
			hitbox = FlxDestroyUtil.destroy(hitbox);
		#end
	}

	public function new(?TransIn:TransitionData, ?TransOut:TransitionData)
	{
		transIn = TransIn;
		transOut = TransOut;

		if (transIn == null && defaultTransIn != null)
		{
			transIn = defaultTransIn;
		}
		if (transOut == null && defaultTransOut != null)
		{
			transOut = defaultTransOut;
		}
		super();
	}

	override public function create():Void
	{
		super.create();
		transitionIn();
	}

	override public function switchTo(nextState:FlxState):Bool
	{
		if (!hasTransOut)
			return true;

		if (!_exiting)
			transitionToState(nextState);

		return transOutFinished;
	}

	function transitionToState(nextState:FlxState):Void
	{
		_exiting = true;
		transitionOut(function()
		{
			FlxG.switchState(nextState);
		});

		if (skipNextTransOut)
		{
			skipNextTransOut = false;
			finishTransOut();
		}
	}

	public function transitionIn():Void
	{
		if (transIn != null && transIn.type != NONE)
		{
			if (skipNextTransIn)
			{
				skipNextTransIn = false;
				if (finishTransIn != null)
				{
					finishTransIn();
				}
				return;
			}

			var _trans = createTransition(transIn);

			_trans.setStatus(FULL);
			openSubState(_trans);

			_trans.finishCallback = finishTransIn;
			_trans.start(OUT);
		}
	}

	public function transitionOut(?OnExit:Void->Void):Void
	{
		_onExit = OnExit;
		if (hasTransOut)
		{
			var _trans = createTransition(transOut);

			_trans.setStatus(EMPTY);
			openSubState(_trans);

			_trans.finishCallback = finishTransOut;
			_trans.start(IN);
		}
		else
		{
			_onExit();
		}
	}

	var transOutFinished:Bool = false;

	var _exiting:Bool = false;
	var _onExit:Void->Void;

	function get_hasTransIn():Bool
	{
		return transIn != null && transIn.type != NONE;
	}

	function get_hasTransOut():Bool
	{
		return transOut != null && transOut.type != NONE;
	}

	function createTransition(data:TransitionData):Transition
	{
		return switch (data.type)
		{
			case TILES: new Transition(data);
			case FADE: new Transition(data);
			default: null;
		}
	}

	function finishTransIn()
	{
		closeSubState();
	}

	function finishTransOut()
	{
		transOutFinished = true;

		if (!_exiting)
		{
			closeSubState();
		}

		if (_onExit != null)
		{
			_onExit();
		}
	}
}
