import std.stdio : writeln, writefln, File;
import std.file : read, mkdirRecurse, isDir, exists;
import std.zip;
import std.string;
import std.path;
import std.getopt;

void unzipArchive(string archName, Settings sets)
{
  auto zip = new ZipArchive(read(archName));

  foreach (name, am; zip.directory)
  {
    if (sets.prefixExtract != null)
      name = sets.prefixExtract ~ name;
    
    if (!sets.silence)
      writeln("\t\033[1mFILE:\033[0m\t" ~ name);

    if (sets.allLowercase)
      name = toLower(name);
    else if (sets.allUpper)
      name = toUpper(name);
    
    mkdirRecurse(dirName(name));

    if (!endsWith(name, "/"))
    {
      File n = File(name, "w");
      n.writeln(cast(string) zip.expand(am));
      n.close();
    }
  }
}

struct Settings
{
  bool allLowercase = false;
  bool allUpper = false;
  string prefixExtract = null;
  bool silence = false;
}

void printHelp(GetoptResult opt)
{
  foreach (Option n; opt.options)
  {
    writeln("\t" ~ n.optShort ~ "\t" ~ n.help);
  }
  writeln("Quickly unzip files from a .zip file.");
}

int main(string[] args)
{
  GetoptResult opt;

  Settings s;

  try
  {
    opt = getopt(args,
      "l", "Make all filenames lowercase", &s.allLowercase,
      "u", "Make all filenames uppercase", &s.allUpper,
      "p", "Extract the directory to this dir instead", &s.prefixExtract,
      "s", "Silently extract files", &s.silence);
  }
  catch (GetOptException e)
  {
    writeln("\033[31;1merror\033[0m: " ~ e.msg ~ ", do `--help` for a list of options.");
    return 1;
  }

  if (opt.helpWanted)
  {
    printHelp(opt);
    return 0;
  }
  if (args.length == 1)
  {
    printHelp(opt);
  }
  else
  {
    unzipArchive(args[1], s);
  }

  return 0;
}
