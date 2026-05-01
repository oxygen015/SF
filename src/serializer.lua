local serializer = {}

function serializer.SafeStr(v)
    local ok, s = pcall(tostring, v)
    return ok and s or "?"
end

function serializer.SerializeValue(val)
    local ok0, t = pcall(typeof, val)
    if not ok0 then return nil end

    if t == "string" then
        local s = val:gsub("\\","\\\\"):gsub('"','\\"')
            :gsub("\n","\\n"):gsub("\r","\\r"):gsub("\0","\\0")
        return '"' .. s .. '"'
    elseif t == "number" then
        if val ~= val or val == math.huge or val == -math.huge then return nil end
        return tostring(val)
    elseif t == "boolean" then
        return tostring(val)
    elseif t == "Color3" then
        local ok,s = pcall(string.format,"Color3.fromRGB(%d,%d,%d)",
            math.clamp(math.floor(val.R*255+.5),0,255),
            math.clamp(math.floor(val.G*255+.5),0,255),
            math.clamp(math.floor(val.B*255+.5),0,255))
        return ok and s or nil
    elseif t == "Vector3" then
        local ok,s = pcall(string.format,"Vector3.new(%g,%g,%g)",val.X,val.Y,val.Z)
        return ok and s or nil
    elseif t == "Vector2" then
        local ok,s = pcall(string.format,"Vector2.new(%g,%g)",val.X,val.Y)
        return ok and s or nil
    elseif t == "CFrame" then
        local ok,s = pcall(string.format,
            "CFrame.new(%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g)",
            val.X,val.Y,val.Z,
            val.RightVector.X,val.RightVector.Y,val.RightVector.Z,
            val.UpVector.X,val.UpVector.Y,val.UpVector.Z,
            -val.LookVector.X,-val.LookVector.Y,-val.LookVector.Z)
        return ok and s or nil
    elseif t == "BrickColor" then
        local ok,name = pcall(function() return val.Name end)
        return ok and name and ('BrickColor.new("'..name:gsub('"','\\"')..'")') or nil
    elseif t == "UDim2" then
        local ok,s = pcall(string.format,"UDim2.new(%g,%g,%g,%g)",
            val.X.Scale,val.X.Offset,val.Y.Scale,val.Y.Offset)
        return ok and s or nil
    elseif t == "UDim" then
        local ok,s = pcall(string.format,"UDim.new(%g,%g)",val.Scale,val.Offset)
        return ok and s or nil
    elseif t == "EnumItem" then
        local ok,s = pcall(tostring,val)
        return ok and s or nil
    elseif t == "Rect" then
        local ok,s = pcall(string.format,"Rect.new(%g,%g,%g,%g)",
            val.Min.X,val.Min.Y,val.Max.X,val.Max.Y)
        return ok and s or nil
    elseif t == "NumberRange" then
        local ok,s = pcall(string.format,"NumberRange.new(%g,%g)",val.Min,val.Max)
        return ok and s or nil
    elseif t == "PhysicalProperties" then
        local ok,s = pcall(string.format,
            "PhysicalProperties.new(%g,%g,%g,%g,%g)",
            val.Density,val.Friction,val.Elasticity,
            val.FrictionWeight,val.ElasticityWeight)
        return ok and s or nil
    elseif t == "NumberSequence" then
        local ok2,kpoints = pcall(function() return val.Keypoints end)
        if not ok2 then return nil end
        local kps={}
        for _,kp in ipairs(kpoints) do
            local ok3,s = pcall(string.format,
                "NumberSequenceKeypoint.new(%g,%g,%g)",kp.Time,kp.Value,kp.Envelope)
            if ok3 then table.insert(kps,s) end
        end
        return "NumberSequence.new({"..table.concat(kps,",").."})"
    elseif t == "ColorSequence" then
        local ok2,kpoints = pcall(function() return val.Keypoints end)
        if not ok2 then return nil end
        local kps={}
        for _,kp in ipairs(kpoints) do
            local ok3,s = pcall(string.format,
                "ColorSequenceKeypoint.new(%g,Color3.fromRGB(%d,%d,%d))",
                kp.Time,
                math.clamp(math.floor(kp.Value.R*255+.5),0,255),
                math.clamp(math.floor(kp.Value.G*255+.5),0,255),
                math.clamp(math.floor(kp.Value.B*255+.5),0,255))
            if ok3 then table.insert(kps,s) end
        end
        return "ColorSequence.new({"..table.concat(kps,",").."})"
    end
    return nil
end

serializer.PROP_BLACKLIST = {
    Parent=true, Children=true, Source=true,
    RobloxLocked=true, SourceAssetId=true,
    UniqueId=true, HistoryId=true,
    PhysicsData=true, CollisionData=true,
    LevelOfDetailData=true, AttributesSerialize=true,
    Tags=true, ScriptGuid=true,
}

serializer.SAFE_PROPS = {
    "Name","Archivable","Transparency","Color","BrickColor","Material",
    "CFrame","Size","Position","Rotation","Anchored","CanCollide","Locked",
    "CastShadow","BackSurface","FrontSurface","LeftSurface","RightSurface",
    "TopSurface","BottomSurface","Font","Text","TextSize","TextColor3",
    "TextTransparency","BackgroundColor3","BackgroundTransparency",
    "BorderSizePixel","ImageColor3","Image","Brightness",
    "MaxActivationDistance","Enabled","Visible","ZIndex",
    "RenderFidelity","CollisionFidelity","Shape","Style",
    "SoundId","Volume","Looped","PlayOnRemove","RollOffMaxDistance",
    "RollOffMinDistance","Pitch",
    "Lifetime","Rate","Speed","SpreadAngle","RotSpeed","Acceleration",
    "Drag","EmissionDirection","LightEmission","LightInfluence",
    "TextureId","ZOffset",
    "Density","Elasticity","Friction","FrictionWeight","ElasticityWeight",
    "CustomPhysicalProperties",
    "Health","MaxHealth","WalkSpeed","JumpPower","JumpHeight","AutoRotate",
    "NameDisplayDistance","HealthDisplayDistance","NameOcclusion",
    "TeamColor","Neutral",
    "MeshId","TextureID","Scale","Offset","MeshType","VertexColor",
    "FieldOfView","NearPlaneZ","CameraType",
    "Ambient","OutdoorAmbient","ClockTime","FogColor",
    "FogEnd","FogStart","GeographicLatitude","TimeOfDay",
    "ShadowSoftness","EnvironmentDiffuseScale","EnvironmentSpecularScale",
    "Value",
}

function serializer.GetProperties(inst)
    local props = {}
    if getproperties then
        local ok, result = pcall(getproperties, inst)
        if ok and type(result) == "table" then
            for k, v in pairs(result) do
                if not serializer.PROP_BLACKLIST[k] then
                    local ok2, sv = pcall(serializer.SerializeValue, v)
                    if ok2 and sv then
                        table.insert(props, {k, sv})
                    end
                end
            end
            return props
        end
    end
    for _, prop in ipairs(serializer.SAFE_PROPS) do
        if not serializer.PROP_BLACKLIST[prop] then
            local ok, val = pcall(function() return inst[prop] end)
            if ok and val ~= nil then
                local ok2, sv = pcall(serializer.SerializeValue, val)
                if ok2 and sv then
                    table.insert(props, {prop, sv})
                end
            end
        end
    end
    return props
end

return serializer
