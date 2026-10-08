#version 330

// Fast 4-Tap Bloom Shader optimized for high-performance GPUs
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

const vec2 size = vec2(1024.0, 650.0);

void main()
{
    vec4 source = texture(texture0, fragTexCoord);
    vec2 offset = vec2(1.5 / size.x, 1.5 / size.y);

    // 4-Tap bilinear corner sampling (fastest bloom filter)
    vec4 blur = (texture(texture0, fragTexCoord + vec2(-offset.x, -offset.y)) +
                 texture(texture0, fragTexCoord + vec2( offset.x, -offset.y)) +
                 texture(texture0, fragTexCoord + vec2(-offset.x,  offset.y)) +
                 texture(texture0, fragTexCoord + vec2( offset.x,  offset.y))) * 0.25;

    float luminance = dot(blur.rgb, vec3(0.299, 0.587, 0.114));

    if (luminance > 0.40)
    {
        finalColor = (source + blur * 0.75) * colDiffuse;
    }
    else
    {
        finalColor = source * colDiffuse;
    }
}
