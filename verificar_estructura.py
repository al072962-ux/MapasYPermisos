"""Valida el paquete Xcode sin necesitar macOS. No compila Swift."""

from pathlib import Path
import json
import plistlib
import re
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parent


def parse_openstep(source):
    pattern = re.compile(
        r'\s+|/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|[{}()=;,]|[^\s{}()=;,"/]+',
        re.DOTALL,
    )
    tokens = []
    cursor = 0
    for match in pattern.finditer(source):
        assert match.start() == cursor, f"Texto inesperado en posición {cursor}"
        cursor = match.end()
        token = match.group()
        if not token.isspace() and not token.startswith(("/*", "//")):
            tokens.append(token)
    assert cursor == len(source), "Texto final sin analizar"
    index = 0

    def consume(expected):
        nonlocal index
        assert tokens[index] == expected, (tokens[index], expected)
        index += 1

    def value():
        nonlocal index
        token = tokens[index]
        index += 1
        if token == "{":
            result = {}
            while tokens[index] != "}":
                key = value()
                assert key not in result, f"Clave duplicada: {key}"
                consume("=")
                result[key] = value()
                consume(";")
            consume("}")
            return result
        if token == "(":
            result = []
            while tokens[index] != ")":
                result.append(value())
                if tokens[index] != ")":
                    consume(",")
            consume(")")
            return result
        assert token not in "{}()=;,", f"Token inesperado: {token}"
        return json.loads(token) if token.startswith('"') else token

    parsed = value()
    assert index == len(tokens), "Contenido extra después del proyecto"
    return parsed


def main():
    project_dir = ROOT / "MapasYPermisos.xcodeproj"
    project = parse_openstep((project_dir / "project.pbxproj").read_text(encoding="utf-8"))
    objects = project["objects"]

    def validate_references(node):
        if isinstance(node, dict):
            for child in node.values():
                validate_references(child)
        elif isinstance(node, list):
            for child in node:
                validate_references(child)
        elif re.fullmatch(r"[A-F0-9]{24}", node):
            assert node in objects, f"Referencia inexistente: {node}"

    validate_references(project)
    pbx_project = objects[project["rootObject"]]
    assert pbx_project["isa"] == "PBXProject"
    paths = {}

    def walk_group(object_id, folder):
        obj = objects[object_id]
        if obj["isa"] == "PBXGroup":
            parent = folder / obj.get("path", "")
            for child in obj["children"]:
                walk_group(child, parent)
        elif obj["isa"] == "PBXFileReference" and obj["sourceTree"] != "BUILT_PRODUCTS_DIR":
            path = folder / obj["path"]
            assert path.is_file(), f"Archivo faltante: {path}"
            paths[object_id] = path

    walk_group(pbx_project["mainGroup"], ROOT)
    target_id, = pbx_project["targets"]
    target = objects[target_id]
    compiled = []
    for phase_id in target["buildPhases"]:
        phase = objects[phase_id]
        if phase["isa"] == "PBXSourcesBuildPhase":
            compiled.extend(paths[objects[file_id]["fileRef"]] for file_id in phase["files"])
    assert len(compiled) == len(set(compiled)), "Fuentes repetidas en el target"
    assert {p.name for p in compiled} == {
        "MapasYPermisosApp.swift", "ContentView.swift", "LocationManager.swift", "Place.swift"
    }
    assert sum("@main" in p.read_text(encoding="utf-8") for p in compiled) == 1

    configuration_list = objects[target["buildConfigurationList"]]
    for configuration_id in configuration_list["buildConfigurations"]:
        settings = objects[configuration_id]["buildSettings"]
        with (ROOT / settings["INFOPLIST_FILE"]).open("rb") as stream:
            info = plistlib.load(stream)
        assert info["NSLocationWhenInUseUsageDescription"].strip()
        assert "location" not in info.get("UIBackgroundModes", [])
        assert "iphonesimulator" in settings["SUPPORTED_PLATFORMS"]

    scheme = ET.parse(project_dir / "xcshareddata/xcschemes/MapasYPermisos.xcscheme")
    for reference in scheme.findall(".//BuildableReference"):
        assert reference.attrib["BlueprintIdentifier"] == target_id
        assert reference.attrib["ReferencedContainer"] == "container:MapasYPermisos.xcodeproj"
    assert scheme.find("LaunchAction").attrib["allowLocationSimulation"] == "YES"

    gpx = ET.parse(ROOT / "Pruebas/RecorridoCampeche.gpx")
    points = gpx.findall("{http://www.topografix.com/GPX/1/1}wpt")
    assert len(points) >= 2
    coordinates = []
    for point in points:
        latitude, longitude = float(point.attrib["lat"]), float(point.attrib["lon"])
        assert -90 <= latitude <= 90 and -180 <= longitude <= 180
        coordinates.append((latitude, longitude))
    assert len(set(coordinates)) > 1

    print(f"OK: proyecto analizado; {len(objects)} objetos y referencias válidas.")
    print(f"OK: {len(compiled)} fuentes únicas, un punto de entrada y archivos presentes.")
    print("OK: permiso iOS, configuraciones Debug/Release y esquema del simulador.")
    print(f"OK: GPX con {len(points)} ubicaciones distintas válidas.")
    print("Pendiente: compilar Swift y ejecutar las pruebas funcionales en Xcode.")


if __name__ == "__main__":
    main()
