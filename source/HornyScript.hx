package;

import hscript.Interp;
import hscript.Parser;
import openfl.Lib;
import flixel.FlxBasic;
import llua.Buffer;
import llua.Convert;
import llua.Lua;
import llua.LuaJIT;
import llua.LuaL;
import llua.LuaOpen;
import llua.State;
import vm.lua.LuaVM;
import hxcodec.vlc.VLCBitmap;
import hxcodec.vlc.LibVLC;
import hxcodec.VideoHandler;
import hxcodec.VideoSprite;
using StringTools;

/*
* Based on Hscript api from fnf wednesdays infidelity by lunarcleint, credits to him
*/
class HornyScript extends FlxBasic {
	
	public var hscript:Interp;
	public var parser:Parser;
        var code:String = '';

	public function new(path:String)
	{
                super();
		code = sys.io.File.getContent(#if android Paths.gamePath() + #end path);
		
		hscript = new Interp();
		
		parser = new Parser();
		parser.allowJSON = true;
		parser.allowTypes = true;
		parser.allowMetadata = true;
		
		setVariable('script', this);
		setVariable('import', function(daClass:String)
		{
			final splitClassName:Array<String> = [for (e in daClass.split('.')) e.trim()];
			final className:String = splitClassName.join('.');
			final daClass:Class<Dynamic> = Type.resolveClass(className);
			final daEnum:Enum<Dynamic> = Type.resolveEnum(className);

			if (daClass == null && daEnum == null)
				Lib.application.window.alert('Class / Enum at $className does not exist.', 'Hscript Error!');
			else
			{
				if (daEnum != null)
				{
					for (daConstructor in daEnum.getConstructors())
						Reflect.setField({}, daConstructor, daEnum.createByName(daConstructor));
					setVariable(splitClassName[splitClassName.length - 1], {});
				}
				else
					setVariable(splitClassName[splitClassName.length - 1], daClass);
			}
		});
		setVariable('Date', Date);
		setVariable('DateTools', DateTools);
		setVariable('EReg', EReg);
		setVariable('Lambda', Lambda);
		setVariable('Math', Math);
		setVariable('Reflect', Reflect);
		setVariable('Std', Std);
		setVariable('StringBuf', StringBuf);
		setVariable('StringTools', StringTools);
		setVariable('Sys', Sys);
		setVariable('Type', Type);
		setVariable('Xml', Xml);
		setVariable('Globals', Globals);
		setVariable('FlxColor', FlxColor_hscript);
		setVariable('HClass', HornyClass);
		setVariable('HState', HornyState);
		setVariable('HSubState', HornySubState);
		setVariable('HObject', HornyObject);
		setVariable('HScript', HornyScript);
                setVariable('Lua_helper', Lua_helper);
                setVariable('Lua_Debug', {
	                "event":Int,
	                "name":String,             // (n)
	                "namewhat":String,         // (n) `global', `local', `field', `method'
	                "what":String,             // (S) `Lua', `C', `main', `tail'
	                "source":String,           // (S)
	                "currentline":Int,         // (l)
	                "nups":Int,                // (u) number of upvalues
	                "linedefined":Int,         // (S)
	                "lastlinedefined":Int,     // (S)
	                "short_src":Array, // (S)
	                "i_ci":Int       // private
                });
                setVariable('LuaVM', LuaVM);
                // vlc shit
                setVariable('VLCBitmap', VLCBitmap);
                setVariable('VideoHandler', VideoHandler);
                setVariable('VideoSprite', VideoSprite);
	}

        public function run()
        {
                try
		{
			var ast:Any = parser.parseString(code);

			hscript.execute(ast);
		}
		catch (e)
		{
			Lib.application.window.alert(e.message, "HSCRIPT ERROR!1111");
		}
        }

	public function setVariable(name:String, val:Dynamic)
	{
		hscript.variables.set(name, val);
	}

	public function getVariable(name:String):Dynamic
	{
		return hscript.variables.get(name);
	}

	public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic
	{
		if (hscript == null)
			return null;

		if (hscript.variables.exists(funcName))
		{
			var func = hscript.variables.get(funcName);
			if (args == null)
			{
				var result = null;
				try
				{
					result = func();
				}
				catch (e)
				{
					trace('$e');
				}
				return result;
			}
			else
			{
				var result = null;
				try
				{
					result = Reflect.callMethod(null, func, args);
				}
				catch (e)
				{
					trace('$e');
				}
				return result;
			}
		}
		return null;
	}

	override public function destroy()
	{
		hscript = null;
		parser = null;
		super.destroy();
	}
}
