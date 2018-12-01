local MODULES =
{
	--"gold",
	"kills",
	"heroSelection",
}

for k,v in pairs(MODULES) do
	ModuleRequire(...,v .. "/" .. v )
end 